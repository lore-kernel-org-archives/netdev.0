From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 1/1] ip-link: add switch to show human readable
 output
Date: Sun, 2 Nov 2014 12:51:59 -0800
Message-ID: <20141102125159.02efa974@urahara>
References: <20141031123115.4cd13371@urahara>
	<1414791193-25192-1-git-send-email-mail@eworm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christian Hesse <mail@eworm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:64884 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaKBUwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 15:52:11 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so10353687pdb.39
        for <netdev@vger.kernel.org>; Sun, 02 Nov 2014 12:52:10 -0800 (PST)
In-Reply-To: <1414791193-25192-1-git-send-email-mail@eworm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 31 Oct 2014 22:33:13 +0100
Christian Hesse <mail@eworm.de> wrote:

> Byte and packet count can increase to really big numbers. This adds a
> switch to show human readable output.
> 
> 4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
>     link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     1523846973 3969051  0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     8710088361 6077735  0       0       0       0
> 4: wl: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP mode DORMANT group default qlen 1000
>     link/ether 00:de:ad:be:ee:ef brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     1.5G       3.9M     0       0       0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     8.7G       6.0M     0       0       0       0

Applied, then I did a code cleanup and added -iec as a option (similar to tc).
