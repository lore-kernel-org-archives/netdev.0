From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 34/39] mv643xx_eth: detect extended rx coal register
	field
Date: Thu, 5 Jun 2008 05:50:49 -0700
Message-ID: <20080605125049.GX3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-35-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:38114 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757528AbYFEMuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:50:54 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-35-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:49PM +0200, Lennert Buytenhek wrote:
> Newer hardware has a 16-bit instead of a 14-bit RX coalescing
> count field in the SDMA_CONFIG register.  This patch adds a run-time
> check for which of the two we have, and adjusts further writes to the
> rx coal count field accordingly.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   38 +++++++++++++++++++++++++++++++-------
>  1 files changed, 31 insertions(+), 7 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
