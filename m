From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 33/39] mv643xx_eth: work around TX hang hardware issue
Date: Thu, 5 Jun 2008 05:37:15 -0700
Message-ID: <20080605123715.GP3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-34-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:57002 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646AbYFEMh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:37:27 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-34-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:48PM +0200, Lennert Buytenhek wrote:
> Under some conditions, the TXQ ('TX queue being served') bit can clear
> before all packets queued for that TX queue have been transmitted.
> This patch enables TXend interrupts, and uses those to re-kick TX
> queues that claim to be idle but still have queued descriptors from
> the interrupt handler.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   35 ++++++++++++++++++++++++++++++-----
>  1 files changed, 30 insertions(+), 5 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
