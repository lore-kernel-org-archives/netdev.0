From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH 2/7] ATM cell alignment.
Date: Fri, 11 Apr 2008 10:18:29 -0400
Message-ID: <200804111418.m3BEITwI019093@cmf.nrl.navy.mil>
References: <Pine.LNX.4.64.0804110650390.16547@ask.diku.dk>
Reply-To: chas3@users.sourceforge.net
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:41590 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807AbYDKOTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 10:19:34 -0400
In-reply-to: <Pine.LNX.4.64.0804110650390.16547@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <Pine.LNX.4.64.0804110650390.16547@ask.diku.dk>,Jesper Dangaard Brou
er writes:
>Yes, I remember.  My original patch also contained some #ifndef's to 
>handle that case.  I cannot remember, but there was some reason why I 
>needed those, something about the ATM part of TC not always being 
>included.

then perhaps just include linux/atm.h in this file. instead of
creating ifdef swiss cheese.
