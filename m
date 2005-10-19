From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.14-rc3 2/3] sundance: probe PHYs from MII address 0
Date: Wed, 19 Oct 2005 08:00:24 -0400
Message-ID: <20051019120022.GA15438@tuxdriver.com>
References: <10182005213101.12810@bilbo.tuxdriver.com> <4355B017.4040509@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750837AbVJSMAr@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4355B017.4040509@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2005 at 10:31:51PM -0400, Jeff Garzik wrote:
> John W. Linville wrote:

> >--- a/drivers/net/sundance.c
> >+++ b/drivers/net/sundance.c
> >@@ -608,7 +608,7 @@ static int __devinit sundance_probe1 (st
> > 
> > 	np->phys[0] = 1;		/* Default setting */
> > 	np->mii_preamble_required++;
> >-	for (phy = 1; phy < 32 && phy_idx < MII_CNT; phy++) {
> >+	for (phy = 0; phy < 32 && phy_idx < MII_CNT; phy++) {
> 
> NAK.  MII address 0 should be scanned _last_, after all other addresses. 
>  In some phys, it is a ghost, mirroring another address.
> 
> Take a look at some of the original Becker MII scan code from
> ftp://ftp.scyld.com/pub/network/ to see an elegant method for this.

Hmmm...that is clever...patch to follow...

John
-- 
John W. Linville
linville@tuxdriver.com
