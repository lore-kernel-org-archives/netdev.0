From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 11/12] r8169: align the IP header when there is no DMA
 constraint
Date: Tue, 08 May 2007 00:53:46 -0400
Message-ID: <4640025A.207@garzik.org>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com> <20070426214929.GL7344@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Philip Craig <philipc@snapgear.com>,
	Mike Isely <isely@pobox.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54127 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967810AbXEHExw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 00:53:52 -0400
In-Reply-To: <20070426214929.GL7344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Align the IP header when the chipset can DMA at any location (plain 0x8169).
> Otherwise (0x8136/0x8168) obey the constraint imposed by the hardware.
> 
> This patch complements the previous alignment rework done for copybreak.
> 
> Original idea from Philip Craig <philipc@snapgear.com>
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Philip Craig <philipc@snapgear.com>
> Cc: Mike Isely <isely@pobox.com>
> ---
>  drivers/net/r8169.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)

ACK patches 10-11


