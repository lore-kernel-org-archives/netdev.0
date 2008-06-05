From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 36/39] mv643xx_eth: be more agressive about RX refill
Date: Thu, 5 Jun 2008 05:48:22 -0700
Message-ID: <20080605124822.GU3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-37-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:58225 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757323AbYFEMsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:48:31 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-37-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:51PM +0200, Lennert Buytenhek wrote:
> During OOM, instead of stopping RX refill when the rx desc ring is
> not empty, keep trying to refill the ring as long as it is not full
> instead.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
