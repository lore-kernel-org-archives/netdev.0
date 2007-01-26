From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH] RFC: Broadcom PHY forcing fix
Date: Fri, 26 Jan 2007 16:19:01 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0701261613550.15582@blysk.ds.pg.gda.pl>
References: <Pine.LNX.4.64.0701251718270.4944@gate.crashing.org>
 <Pine.LNX.4.64N.0701261426040.15582@blysk.ds.pg.gda.pl>
 <59B2B1AE-76A3-4D1E-A17B-4E4B15B25CFA@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:1331 "EHLO
	pollux.ds.pg.gda.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030623AbXAZQTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 11:19:06 -0500
In-Reply-To: <59B2B1AE-76A3-4D1E-A17B-4E4B15B25CFA@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 26 Jan 2007, Kumar Gala wrote:

> It looks like phy_timer has changed a bit in 2.6.20-rc6, what exactly was the
> intent of these changes?

 As I wrote, I'll have a look at these patches after 2.6.20 again.  These 
bits are from September (see the timestamps) and some of them may well 
have become irrelevant.

 The additional timeout was meant to let the driver go back to 
autonegotiation once a cycle through all the forced speeds has failed.

  Maciej
