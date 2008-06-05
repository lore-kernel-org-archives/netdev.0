From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 38/39] mv643xx_eth: add PHY-less mode
Date: Thu, 5 Jun 2008 05:49:44 -0700
Message-ID: <20080605124944.GW3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-39-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:58274 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757398AbYFEMtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:49:51 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-39-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:53PM +0200, Lennert Buytenhek wrote:
> On some boards, the mv643xx_eth MAC isn't connected to a PHY but
> directly (via the MII/GMII/RGMII interface) to another MAC-layer
> device.  This patch allows specifying ->phy_addr = -1 to skip all
> PHY-related initialisation and run-time poking in that case.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   87 ++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 74 insertions(+), 13 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
