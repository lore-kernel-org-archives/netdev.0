From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 24/39] mv643xx_eth: kill private unused instance of
	struct net_device_stats
Date: Thu, 5 Jun 2008 05:08:14 -0700
Message-ID: <20080605120814.GL3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-25-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:53525 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756433AbYFEMIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:08:19 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-25-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:39PM +0200, Lennert Buytenhek wrote:
> The per-port mv643xx_eth_private struct had a private instance
> of struct net_device_stats that was never ever written to, only
> read (via the ethtool statistics interface).  This patch gets
> rid of the private instance, and tweaks the ethtool statistics
> code in mv643xx_eth to use the statistics in struct net_device
> instead.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |  120 +++++++++++++++++++++++++--------------------
>  1 files changed, 66 insertions(+), 54 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
