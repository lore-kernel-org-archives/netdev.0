From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: sbc8641: drop bogus PHY IRQ entries from DTS file
Date: Mon, 14 Dec 2015 20:46:38 +1100 (AEDT)
Message-ID: <20151214094638.87145140557@ozlabs.org>
References: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:47445 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932105AbbLNJqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2015 04:46:39 -0500
In-Reply-To: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-12 at 22:44:02 UTC, Paul Gortmaker wrote:
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
> 
> Cc: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied to powerpc fixes, thanks.

https://git.kernel.org/powerpc/c/5b01310cfc8d2302dcca1d8d

cheers
