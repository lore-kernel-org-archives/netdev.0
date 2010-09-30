From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Moved enabling of MSI to the
 bnx2x_set_num_queues()
Date: Wed, 29 Sep 2010 19:48:39 -0700 (PDT)
Message-ID: <20100929.194839.27796665.davem@davemloft.net>
References: <1285758337.7908.7.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vladz@broadcom.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34996
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752796Ab0I3CsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 22:48:18 -0400
In-Reply-To: <1285758337.7908.7.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 29 Sep 2010 13:05:37 +0200

>  Moved enabling of MSI to the bnx2x_set_num_queues() - the same functions that
>  handles the initialization of the MSI-X.
> 
> From: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
> Respin of the patch originally prepared by Vladislav Zolotarov.
> This patch is required for the integration of Ben Hutchings bnx2x patch from
> the "netif_set_real_num_{rx,tx}_queues" patch series. Since falling from MSI-X
> to MSI mode due to lack of memory is broken.

Applied, thanks.
