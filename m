From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [RFC PATCH 08/10] be2net: remove use of skb_dma_map/unmap
Date: Fri, 27 Nov 2009 14:28:07 +0530
Message-ID: <20091127085805.GA8808@serverengines.com>
References: <20091125011111.32704.3009.stgit@gitlad.jf.intel.com>
 <20091125012054.32704.71183.stgit@gitlad.jf.intel.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	sathyap@serverengines.com, subbus@serverengines.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:34759 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751505AbZK0I6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 03:58:07 -0500
Content-Disposition: inline
In-Reply-To: <20091125012054.32704.71183.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/11/09 17:20 -0800, Alexander Duyck wrote:
> Due to the fact that skb_dma_map/unmap do not work correctly when a HW
> IOMMU is enabled it has been recommended to go about removing the calls
> from the network device drivers.
>     
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> 
>  drivers/net/benet/be_main.c |   37 ++++++++++++++++++++++++++-----------
>  1 files changed, 26 insertions(+), 11 deletions(-)
> 
Thanks for the changes. They are good to go.

Acked-by: Ajit Khaparde <ajitk@serverengines.com>
