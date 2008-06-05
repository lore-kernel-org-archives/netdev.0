From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 22/39] mv643xx_eth: move rx_return_buff() into its only
	caller
Date: Thu, 5 Jun 2008 05:01:51 -0700
Message-ID: <20080605120151.GH3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-23-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51202 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755497AbYFEMB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:01:59 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-23-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:37PM +0200, Lennert Buytenhek wrote:
> rx_return_buff() is also a remnant of the HAL layering that the
> original mv643xx_eth driver used.  Moving it into its caller kills
> the last reference to FUNC_RET_STATUS/pkt_info.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   80 ++++++++++++++++-----------------------------
>  1 files changed, 28 insertions(+), 52 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
