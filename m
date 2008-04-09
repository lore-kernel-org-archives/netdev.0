From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: [PATCH 0/7] Final ADSL-optimizer patch series
Date: Wed, 9 Apr 2008 22:57:25 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804092249550.21022@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:54262 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753894AbYDIU52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2008 16:57:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the final part of the ADSL-optimizer patch, which is the real
"holy grail" of packet scheduling on ADSL/ATM lines. (Referring to
Wondershaper claim of the "holy grail".)

Shaping on ADSL has always been surrounded with mystique.  People
reduce and tweek the upstream bandwidth, but how much and why does it
not work all the time?  With this change, the tweeking and bandwidth
waste is gone, simply specify the bandwidth you bought.

This patch series introduces a parameter called "linklayer", which
currently supports "ethernet" and "atm".  Simply, what happens is,
that the rate table is aligned for ATM cells.

This is a general implementation for all shapers, except HFSC which
does not use rate table lookups.  Earlier (around Sep.2007), Patrick
McHardy wanted to make an even more general patch, that also included
HFSC. Nothing has happened since...

After talking with DaveM (at his house during an icehocky match), I've
come to the conclusion that we have something that works now (and has
been since Oct.2004) and we should use it!  Everybody is allowed to
change and improve upon that. Its should not mean that we keep
something like this back, which will allow packet scheduling to
actually work on ADSL.  One should also realize that different shapers
have different properties.

Patrick's further improvements can use the same userspace parameter
"linklayer" to allow userspace parameter compatibility.

This patch series is ABI (Application Binary Interface) compatible.

See you around,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
