From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 32/39] mv643xx_eth: allow multiple TX queues
Date: Thu, 5 Jun 2008 05:41:45 -0700
Message-ID: <20080605124145.GS3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-33-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:41034 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757026AbYFEMlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:41:52 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-33-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:47PM +0200, Lennert Buytenhek wrote:
> As with the multiple RX queue support, allow the platform code to
> specify that the hardware we are running on supports multiple TX
> queues.  This patch only uses the highest-numbered enabled queue
> to send packets to for now, this can be extended later to enable
> QoS and such.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c   |  146 ++++++++++++++++++++++++++++++-------------

Acked-by: Dale Farnsworth <dale@farnsworth.org>
