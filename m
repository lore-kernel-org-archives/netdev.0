From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [BUG] netxen: Stops working between 2.6.30 and 2.6.31-rc1
Date: Thu, 19 Nov 2009 14:11:33 -0800
Message-ID: <7608421F3572AB4292BB2532AE89D5658B0B95BDC9@AVEXMB1.qlogic.org>
References: <20091119163908.GJ14661@jayr.de>
 <7608421F3572AB4292BB2532AE89D5658B0B95BD5C@AVEXMB1.qlogic.org>
 <20091119183607.GK14661@jayr.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amit Salecha <amit.salecha@qlogic.com>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:41583 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbZKSWMl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 17:12:41 -0500
In-Reply-To: <20091119183607.GK14661@jayr.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sorry, I forgot to mention that all later kernels that I tested
> including 2.6.31 and the current net-2.6 also fail, so the badness
> comes in somewhere in between 2.6.30 and 2.6.31-rc1.
> 
> I also noticed that the newer kernel allocate four interrupts for the
> card instead of only one, but none of them seem to get triggered, the
> /proc/interrupts counters all stay at zero.

What firmware revision you have? Since you are saying nothing
transmitted as well, I doubt if you have a link. Otherwise I
would imagine kernel tries to send some neighbor solicitation
crap as soon as you bring up interface. What does your
"ethtool ethx" say about the link? 

It's possible to bisect commits which applied in driver/net/netxen.
That way you have fewer commits to rewind and remains focused on
the driver rather than screwing scsi.

Thanks,
Dhananjay
