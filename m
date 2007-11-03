From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: urgent!  linux 2.6.16 network bridge crash
Date: Sat, 03 Nov 2007 19:20:03 +0100
Message-ID: <472CBBD3.10403@o2.pl>
References: <200711031904486275450@tom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: auther_bin <auther_bin@tom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:46424 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754913AbXKCSSB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 14:18:01 -0400
In-Reply-To: <200711031904486275450@tom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

auther_bin wrote, On 11/03/2007 12:11 PM:

> Hello friends, I have config my linux box works as a network bridge. and
> up/down switch is both cisco 35xx works with vlan. but when i connect it
> into the network the box crashed right now. Puzzled!
> 
> btw, in the down(intranet) switch we connect 8 wireless AP.
> 
> tcpdump gives many many broadcast package like:
> 
> time serial M SRC_MAC > 1:0:0:0:0:0 sap aa ui/C
> 
> what's it?
> flood? or the AP package or the cisco vlan? but whatever it is, the box
> should not be crashed by it, right?
> 
> if the box do not use bridge, it will not crash at all.


Hi friend,

There is not much information (crash is more crash or more lockup?), so you
can only guess. Looks like a multicast problem (vs. vlan or bridge). Maybe
because of wrong MAC like here:

http://lkml.org/lkml/2007/5/12/83

Otherwise you should try to enable and send more debbugging.

Regards,
Jarek P.
