From: Willy Tarreau <w@1wt.eu>
Subject: Re: [2.6.20.17 review 35/58] forcedeth bug fix: realtek phy
Date: Wed, 22 Aug 2007 18:10:17 +0200
Message-ID: <20070822161017.GB11973@1wt.eu>
References: <20070822083844.%N@1wt.eu> <20070822084026.%N@1wt.eu> <46CC5CBA.2050901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, stable@kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:2250 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932466AbXHVQX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 12:23:28 -0400
Content-Disposition: inline
In-Reply-To: <46CC5CBA.2050901@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 22, 2007 at 11:56:42AM -0400, Chuck Ebbert wrote:
> On 08/22/2007 05:39 AM, Willy Tarreau wrote:
> > This patch contains errata fixes for the realtek phy. It only renamed the
> > defines to be phy specific.
> > 
> > Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> > Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> > Signed-off-by: Willy Tarreau <w@1wt.eu>
> > ---
> >  drivers/net/forcedeth.c |   54 +++++++++++++++++++++++++++++++++++++++++++++++
> >  1 files changed, 54 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> > index c383dc3..dbfdbed 100644
> > --- a/drivers/net/forcedeth.c
> > +++ b/drivers/net/forcedeth.c
> > @@ -554,6 +554,7 @@ union ring_type {
> >  #define PHY_OUI_MARVELL	0x5043
> >  #define PHY_OUI_CICADA	0x03f1
> >  #define PHY_OUI_VITESSE	0x01c1
> > +#define PHY_OUI_REALTEK	0x01c1
> >  #define PHYID1_OUI_MASK	0x03ff
> >  #define PHYID1_OUI_SHFT	6
> >  #define PHYID2_OUI_MASK	0xfc00
> 
> Realtek is 0x0732
> 
> This is still wrong upstream -- what happened to the patch to fix it?

Good catch, thanks Chuck! I've already seen the fix somewhere, I believe it
was on netdev, though I'm not sure. I'm fixing the patch in place right now.
I can add your signoff if you want.

Cheers,
Willy

