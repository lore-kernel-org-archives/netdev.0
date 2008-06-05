From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 21/39] mv643xx_eth: move port_receive() into its only
	caller
Date: Thu, 5 Jun 2008 04:53:56 -0700
Message-ID: <20080605115356.GE3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-22-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:57752 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755601AbYFELyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 07:54:00 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-22-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:36PM +0200, Lennert Buytenhek wrote:
> The port_receive() function is a remnant of the original mv643xx_eth
> HAL split.  This patch moves port_receive() into its caller, so that
> the top and the bottom half of RX processing no longer communicate
> via the HAL FUNC_RET_STATUS/pkt_info mechanism abstraction anymore.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   91 ++++++++++++++++-----------------------------
>  1 files changed, 32 insertions(+), 59 deletions(-)

Hooray!

Acked-by: Dale Farnsworth <dale@farnsworth.org>
