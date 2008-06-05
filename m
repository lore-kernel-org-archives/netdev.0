From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 17/39] mv643xx_eth: use 'mv643xx_eth_' prefix
	consistently
Date: Thu, 5 Jun 2008 04:59:04 -0700
Message-ID: <20080605115903.GF3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-18-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:56861 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755939AbYFEL7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:59:13 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-18-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:32PM +0200, Lennert Buytenhek wrote:
> A bunch of places in the mv643xx_eth driver use the 'mv643xx_'
> prefix.  Since the mv643xx is a chip that includes more than just
> ethernet, this patch makes all those places use either no prefix
> (for some internal-use-only functions), or the full 'mv643xx_eth_'
> prefix.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c | 1169 +++++++++++++++++++++++----------------------
>  1 files changed, 585 insertions(+), 584 deletions(-)

I'm not sure it's worth changing all the local vars from mp to mep,
but it's not a big deal.

Acked-by: Dale Farnsworth <dale@farnsworth.org>
