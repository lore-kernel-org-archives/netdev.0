From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] sbc8641: drop bogus PHY IRQ entries from DTS file
Date: Wed, 09 Dec 2015 14:00:03 +1100
Message-ID: <1449630003.6028.14.camel@ellerman.id.au>
References: <1449614642-8161-1-git-send-email-paul.gortmaker@windriver.com>
	 <20151208.214055.912759732176162258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, paulus@samba.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, andrew@lunn.ch
To: David Miller <davem@davemloft.net>, paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:37218 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbbLIDAE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 22:00:04 -0500
In-Reply-To: <20151208.214055.912759732176162258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-08 at 21:40 -0500, David Miller wrote:
>  From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Tue, 8 Dec 2015 17:44:02 -0500
> > This file was originally cloned off of the MPC8641D-HPCN reference
> > platform, which actually had a PHY IRQ line connected.  However
> > this board does not.  The bogus entry was largely inert and went
> > undetected until commit 321beec5047af83db90c88114b7e664b156f49fe
> > ("net: phy: Use interrupts when available in NOLINK state") was
> > added to the tree.
> >
> > With the above commit, the board fails to NFS boot since it sits
> > waiting for a PHY IRQ event that of course never arrives.  Removing
> > the bogus entries from the DTS file fixes the issue.
> >
> > Cc: Andrew Lunn <andrew@lunn.ch>
> > Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>
> I'm assuming this will go via the powerpc tree, not mine.

Yep I'll take it.

cheers
