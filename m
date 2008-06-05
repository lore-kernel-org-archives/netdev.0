From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 13/39] mv643xx_eth: move MIB offset defines into their
	only user
Date: Thu, 5 Jun 2008 04:47:43 -0700
Message-ID: <20080605114743.GB3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-14-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:52727 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541AbYFELrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:47:47 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-14-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:28PM +0200, Lennert Buytenhek wrote:
> The only user of the ETH_MIB_VERY_LONG_NAME_HERE defines is the
> eth_update_mib_counters() function.  Get rid of the defines by
> open-coding the register offsets in the latter.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   92 ++++++++++++++++----------------------------
>  1 files changed, 34 insertions(+), 58 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
