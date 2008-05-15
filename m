From: Nate Case <ncase@xes-inc.com>
Subject: Re: [PATCH] PHYLIB: Add 1000Base-X support for Broadcom bcm5482
Date: Thu, 15 May 2008 16:03:55 -0500
Message-ID: <1210885435.13845.512.camel@localhost.localdomain>
References: <1210695378.13845.362.camel@localhost.localdomain>
	 <Pine.LNX.4.55.0805140018340.7267@cliff.in.clinika.pl>
	 <1210804791.13845.423.camel@localhost.localdomain>
	 <Pine.LNX.4.55.0805142354530.15223@cliff.in.clinika.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:50773 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754947AbYEOVEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 17:04:01 -0400
In-Reply-To: <Pine.LNX.4.55.0805142354530.15223@cliff.in.clinika.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-05-15 at 00:15 +0100, Maciej W. Rozycki wrote:
>  OK.  One note on this occasion: please keep the registers sorted by the
> index.  I missed it with the original review, but the additional registers
> at 0x15, 0x17 and 0x18 (and the values within) should be placed between
> MII_BCM54XX_ESR at 0x11 and MII_BCM54XX_ISR at 0x1a.

Fixed this in patch v3 (coming up shortly).

>  I was a bit worried how it plays with actually trying to force different,
> perhaps incompatible, link parameters.

I didn't try forcing speeds from userspace, but the worst I can envision
happening is that after forcing 10mbit/s or half-duplex mode (for
example) it would still report 1000mbit/s FD.  The forcing itself would
probably not report an error, though you could argue that it should.  My
understanding is that the hardware will take the writes but ignore those
registers in 1000Base-X mode.

-- 
Nate Case <ncase@xes-inc.com>

