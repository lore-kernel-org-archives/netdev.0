From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/4]
 ucc_geth-fix-build-break-introduced-by-commit-09f75cd7bf13720738e6a196cc0107ce9a5bd5a0-checkpatch-fixes
Date: Wed, 17 Oct 2007 19:37:21 -0700 (PDT)
Message-ID: <20071017.193721.48531740.davem@davemloft.net>
References: <200710162124.l9GLOCTB017977@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	Emilian.Medve@Freescale.com, galak@gate.crashing.org,
	leoli@Freescale.com, paulus@samba.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46127
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752331AbXJRChW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:37:22 -0400
In-Reply-To: <200710162124.l9GLOCTB017977@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Tue, 16 Oct 2007 14:24:12 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Emil Medve <Emilian.Medve@Freescale.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Kumar Gala <galak@gate.crashing.org>
> Cc: Li Yang <leoli@freescale.com>
> Cc: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Please help my eyes, I can't see the fix:

> @@ -3454,7 +3454,7 @@ static int ucc_geth_rx(struct ucc_geth_p
>  	u16 length, howmany = 0;
>  	u32 bd_status;
>  	u8 *bdBuffer;
> -	struct net_device * dev;
> +	struct net_device *dev;
>  
>  	ugeth_vdbg("%s: IN", __FUNCTION__);
>  

This might be a coding style fix, as far as I can see, but I can't
imagine how it can effect compilation at all.  It just removes a space
between the "*" and "dev" but that space is harmless.
