From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Tue, 11 Feb 2014 03:44:03 +0100
Message-ID: <20140211024403.GE11150@order.stressinduktion.org>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <1720760.5dnaEcLin5@h2o.as.studentenwerk.mhn.de> <20140207222227.GC16198@order.stressinduktion.org> <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45064 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbaBKCoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 21:44:04 -0500
Content-Disposition: inline
In-Reply-To: <1581659.JtJ1UQaXJr@h2o.as.studentenwerk.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 09, 2014 at 12:17:15AM +0100, Wolfgang Walter wrote:
> host A (which shows the problem with kernel 3.13):
> 
> $ ip addr ls eth0
> 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP 
> group default qlen 1000
>     link/ether 11:22:33:44:55:66 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.1.1/24 brd 192.168.1.255 scope global eth0
>        valid_lft forever preferred_lft forever
>     inet6 2001:1111:2222:aaaa:0:5efe:c0a8:101/120 scope global 
>        valid_lft forever preferred_lft forever
>     inet6 fe80::1322:33ff:fe44:5566/64 scope link 
>        valid_lft forever preferred_lft forever

What driver does this interface use?

ethtool -i eth0

Greetings,

  Hannes
