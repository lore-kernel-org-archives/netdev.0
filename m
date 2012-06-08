From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Fri, 08 Jun 2012 11:41:55 +0200
Message-ID: <1339148515.6001.65.camel@edumazet-glaptop>
References: <ddae4973ddff0015d239dd66551be209@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:54422 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759779Ab2FHJl7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 05:41:59 -0400
Received: by eeit10 with SMTP id t10so957369eei.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 02:41:58 -0700 (PDT)
In-Reply-To: <ddae4973ddff0015d239dd66551be209@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-08 at 10:58 +0200, Nie=C5=9Bcierowicz Adam wrote:
> Hello,
>=20
> recently we changed on the router kernel from 2.6.38.1 to 3.4.1 and=20
> noticed
> 30% packet loss when traffic increases up to 250MB / s.
>=20
> Similar is for kernel 3.5-rc1
>=20
> Here a link to ifstat http://wklej.org/id/767577/

You should give as much as possible delails on your setup (hardware,
software)

lspci
cat /proc/cpuinfo
cat /proc/interrupts
ifconfig -a
tc -s -d qdisc
dmesg
netstat -s
