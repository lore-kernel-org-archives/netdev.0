From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Tue, 7 Jul 2009 15:57:42 +0200
Message-ID: <20090707135742.GB6798@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de> <200907071522.06812.andres@anarazel.de> <20090707132937.GA6798@ami.dom.local> <200907071534.07619.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joao Correia <joaomiguelcorreia@gmail.com>,
	Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:45852 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754791AbZGGN6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 09:58:15 -0400
Content-Disposition: inline
In-Reply-To: <200907071534.07619.andres@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2009 at 03:34:07PM +0200, Andres Freund wrote:
...
> Testing wether its triggerable inside a vm might be interesting...

Probably similarly to testing without this patch or even less. Maybe
I should've warned you but this type of bugs in -rc with possible
memory or stack overwrites might be fatal for your data (at least).

Jarek P.
