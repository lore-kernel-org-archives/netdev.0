From: "Henry Ptasinski" <henryp@broadcom.com>
Subject: Re: [RFC PATCH net-next] if_ether.h: Add #define ETH_P_LARQ for
 HPNA/LARQ
Date: Mon, 13 Dec 2010 17:49:20 -0800
Message-ID: <20101214014920.GA2453@broadcom.com>
References: <1292287667.26970.114.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Brett Rudley" <brudley@broadcom.com>,
	"Dowan Kim" <dowan@broadcom.com>,
	"Henry Ptasinski" <henryp@broadcom.com>, arend@broadcom.com,
	rvossen@broadcom.com
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2651 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758939Ab0LNBti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 20:49:38 -0500
In-Reply-To: <1292287667.26970.114.camel@Joe-Laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 04:47:47PM -0800, Joe Perches wrote:
> LARQ seems to be used by Broadcom's staging driver.
> Might as well add a #define for it to the normal location.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  include/linux/if_ether.h |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> index f9c3df0..b257e99 100644
> --- a/include/linux/if_ether.h
> +++ b/include/linux/if_ether.h
> @@ -71,6 +71,8 @@
>  #define ETH_P_PPP_SES	0x8864		/* PPPoE session messages	*/
>  #define ETH_P_MPLS_UC	0x8847		/* MPLS Unicast traffic		*/
>  #define ETH_P_MPLS_MC	0x8848		/* MPLS Multicast traffic	*/
> +#define ETH_P_LARQ	0x886c		/* HPNA / Broadcom
> +					 * Limited Automatic Repeat reQuest */


That should be ETH_P_BRCM (or ETH_P_EPIGRAM).  HPNA/ILCP used a range of
subtypes for LARQ and other HPNA protocols.  The brcmfmac driver uses a
different subypte for encapsulating some event signals between the device and
the host, but doesn't implement any of the HPNA protocols.

- Henry


