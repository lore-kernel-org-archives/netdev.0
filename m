From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4]
 ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
Date: Wed, 17 Oct 2007 19:47:59 -0700
Message-ID: <20071017194759.bc3571b3.akpm@linux-foundation.org>
References: <200710162124.l9GLOCTB017977@imap1.linux-foundation.org>
	<20071017.193721.48531740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Emilian.Medve@Freescale.com, galak@gate.crashing.org,
	leoli@Freescale.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41585 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763659AbXJRCsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:48:17 -0400
In-Reply-To: <20071017.193721.48531740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 17 Oct 2007 19:37:21 -0700 (PDT) David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Tue, 16 Oct 2007 14:24:12 -0700
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Cc: Emil Medve <Emilian.Medve@Freescale.com>
> > Cc: Jeff Garzik <jeff@garzik.org>
> > Cc: Kumar Gala <galak@gate.crashing.org>
> > Cc: Li Yang <leoli@freescale.com>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Please help my eyes, I can't see the fix:
> 
> > @@ -3454,7 +3454,7 @@ static int ucc_geth_rx(struct ucc_geth_p
> >  	u16 length, howmany = 0;
> >  	u32 bd_status;
> >  	u8 *bdBuffer;
> > -	struct net_device * dev;
> > +	struct net_device *dev;
> >  
> >  	ugeth_vdbg("%s: IN", __FUNCTION__);
> >  
> 
> This might be a coding style fix, as far as I can see, but I can't
> imagine how it can effect compilation at all.  It just removes a space
> between the "*" and "dev" but that space is harmless.

uh, this is fallout from the akpmbot.

- Someone sent a patch which I named foo.patch

- When I applied it I saw valid checkpatch warnings, so I queed a patch to
fix them, called foo-checkpatch-fixes.patch with the intention that it later be
folded into foo.patch

- You merged foo.patch.  But foo-checkpatch-fixes.patch still applied, so I
retained it.

- I sent you the runt foo-checkpatch-fixes.patch.

Normally when this happens I'll just curse the original patch author and
drop foo-checkpatch-fixes.patch.  This time I didn't notice.

(Perhaps people should be adding a checkpatch run to their git-commit
scripts..)

