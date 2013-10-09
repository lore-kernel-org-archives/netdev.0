From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Wed, 9 Oct 2013 13:24:54 +0900
Message-ID: <20131009042454.GA16885@verge.net.au>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp>
 <20131008.160446.1960731810404939922.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nh-ky@jinso.co.jp, netdev@vger.kernel.org,
	ryusuke.sakato.bx@renesas.com, sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36757 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3JIEY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 00:24:58 -0400
Content-Disposition: inline
In-Reply-To: <20131008.160446.1960731810404939922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 08, 2013 at 04:04:46PM -0400, David Miller wrote:
> From: Nguyen Hong Ky <nh-ky@jinso.co.jp>
> Date: Mon,  7 Oct 2013 15:29:24 +0900
> 
> > This patch will fix RX packets errors when receiving big size of data.
> > Moreover, I set suitable parameters for get more stable when receiving
> > packets.
> > 
> > It was created on the top of mainline kernel v3.11.
> > 
> > I tested this patch on Armadillo800eva, it appears to be working well.
> > 
> > Would you please review and apply it for me.
> 
> Applied, but at some point someone has to add definitions for the
> RMCR register fields so that this driver is not full of magic constants.

Sergei, would it be possible for you to address this?
