From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] sbc8641: drop bogus PHY IRQ entries from DTS file
Date: Wed, 09 Dec 2015 14:04:19 +1100
Message-ID: <1449630259.6028.15.camel@ellerman.id.au>
References: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
	 <1449623421.6028.13.camel@ellerman.id.au>
	 <20151209020443.GL22885@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, Andrew Lunn <andrew@lunn.ch>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:33648 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbbLIDEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 22:04:21 -0500
In-Reply-To: <20151209020443.GL22885@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-08 at 21:04 -0500, Paul Gortmaker wrote:
> [Re: [PATCH] sbc8641: drop bogus PHY IRQ entries from DTS file] On 09/12/2015 (Wed 12:10) Michael Ellerman wrote:
> > On Tue, 2015-12-08 at 17:44 -0500, Paul Gortmaker wrote:
> > > This file was originally cloned off of the MPC8641D-HPCN reference
> > > platform, which actually had a PHY IRQ line connected.  However
> > > this board does not.  The bogus entry was largely inert and went
> > > undetected until commit 321beec5047af83db90c88114b7e664b156f49fe
> > > ("net: phy: Use interrupts when available in NOLINK state") was
> > > added to the tree.
> > >
> > > With the above commit, the board fails to NFS boot since it sits
> > > waiting for a PHY IRQ event that of course never arrives.  Removing
> > > the bogus entries from the DTS file fixes the issue.
> >
> > Commit 321beec5047a ("net: phy: Use interrupts when available in NOLINK state")
> > went into 4.4-rc2, so this is a fix for 4.4 right?
>
> Correct, but I'm guessing there are not thousands of users of this board
> out there, so it probably doesn't matter a whole lot if it goes in the
> same release where the regression happened or one release later...

OK sure. As it happens I'm just prepping a fixes branch, so I'll drop it in.

cheers
