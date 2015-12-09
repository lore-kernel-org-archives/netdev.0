From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] sbc8641: drop bogus PHY IRQ entries from DTS file
Date: Wed, 9 Dec 2015 04:07:29 +0100
Message-ID: <20151209030729.GA2093@lunn.ch>
References: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33533 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752552AbbLIDHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 22:07:42 -0500
Content-Disposition: inline
In-Reply-To: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 05:44:02PM -0500, Paul Gortmaker wrote:
> This file was originally cloned off of the MPC8641D-HPCN reference
> platform, which actually had a PHY IRQ line connected.  However
> this board does not.  The bogus entry was largely inert and went
> undetected until commit 321beec5047af83db90c88114b7e664b156f49fe
> ("net: phy: Use interrupts when available in NOLINK state") was
> added to the tree.
> 
> With the above commit, the board fails to NFS boot since it sits
> waiting for a PHY IRQ event that of course never arrives.  Removing
> the bogus entries from the DTS file fixes the issue.

Hi Paul

Originally the interrupt is used for detecting the link has gone
down. That would of also been bogus before. Have you tried this?  If
that is also broken, maybe you need to add a fixes: tag so that it
gets back ported?

     Andrew
