From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Fri, 08 Jun 2012 11:43:36 +0200
Message-ID: <1339148616.6001.67.camel@edumazet-glaptop>
References: <ddae4973ddff0015d239dd66551be209@justnet.pl>
	 <1339148515.6001.65.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56878 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759779Ab2FHJnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 05:43:41 -0400
Received: by eaak11 with SMTP id k11so949626eaa.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 02:43:40 -0700 (PDT)
In-Reply-To: <1339148515.6001.65.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 11:41 +0200, Eric Dumazet wrote:
> On Fri, 2012-06-08 at 10:58 +0200, Nie=C5=9Bcierowicz Adam wrote:

> lspci
> cat /proc/cpuinfo
> cat /proc/interrupts
> ifconfig -a
> tc -s -d qdisc
> dmesg
> netstat -s
>=20

cat /proc/net/softnet_stat
lsmod
