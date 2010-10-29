From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/15] dec netdev: relocate DIGITAL based drivers to
 legacy
Date: Thu, 28 Oct 2010 21:29:39 -0700 (PDT)
Message-ID: <20101028.212939.189691515.davem@davemloft.net>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
	<1288315159-1350-6-git-send-email-paul.gortmaker@windriver.com>
	<alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960Ab0J2E3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 00:29:16 -0400
In-Reply-To: <alpine.LFD.2.00.1010290516110.25426@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Fri, 29 Oct 2010 05:21:35 +0100 (BST)

> On Thu, 28 Oct 2010, Paul Gortmaker wrote:
> 
>> DEC as a name brand has been gone for over 10 years, and these
>> drivers represent technology from the 1990's like the venerable
>> ISA bus.  Hence relocate them to the legacy dir.
> 
>  NAK for the TURBOchannel bits (defxx.[ch] and declance.c) unless you give 
> a plausible justification.  You won't get these drivers offered unless you 
> have the bus in your system anyway, and if you do than you don't want to 
> have them hidden somewhere in the corner.  If you see anything wrong with 
> these drivers, then please do let me know.
> 
>  Also defxx.c is PCI too (apart from being EISA and TC).

PCI things can be legacy too.

This is not about a specific bus technology, it's simply for
"really old stuff" so we can declutter the top-level of drivers/net

