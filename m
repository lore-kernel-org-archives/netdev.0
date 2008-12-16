From: "Tvrtko A. Ursulin" <tvrtko@ursulin.net>
Subject: Bonding gigabit and fast?
Date: Tue, 16 Dec 2008 19:39:29 +0000
Message-ID: <200812161939.30033.tvrtko@ursulin.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mk-outboundfilter-5-a-2.mail.uk.tiscali.com ([212.74.114.4]:47029
	"EHLO mk-outboundfilter-5-a-2.mail.uk.tiscali.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731AbYLPTje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2008 14:39:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi to all,

Does it make any sense from bandwith point of view to bond gigabit and fast 
ethernet?

I wanted to use adaptive-alb mode to load balance both transmit and receive 
direction of traffic but it seems 8139too does not support it so I use 
balance-rr.

When serving data from the machine I get 13.7 MB/s aggregated while with a 
single slave (so bond still active) I get 5.6 MB/s for gigabit and 9.1 MB/s 
for fast. Yes, that's not a typo - fast ethernet is faster than gigabit.

That is actually another problem I was trying to get to the bottom of for some 
time. Gigabit adapter is skge in a PCI slot and outgoing bandwith oscillates 
a lot during transfer, much more than on 8139too which is both stable and 
faster.

Unfortunately this machine takes low-profile cards and so far I was unable to 
find something other than skge to test with.

Oh and yes, kernel is 2.6.27(-9-generic, so Ubuntu derivative of 2.6.27).

Tvrtko


