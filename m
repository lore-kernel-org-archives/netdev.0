From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] igb: reduce Rx header size
Date: Thu, 02 Aug 2012 08:43:10 -0700
Message-ID: <501AA00E.3010400@intel.com>
References: <1342912142-11130-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1342912142-11130-8-git-send-email-jeffrey.t.kirsher@intel.com> <1343920538.9299.200.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36841 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab2HBPnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2012 11:43:11 -0400
In-Reply-To: <1343920538.9299.200.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/02/2012 08:15 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Reduce skb truesize by 256 bytes.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
> Tested on my machine without any problem
>
>  drivers/net/ethernet/intel/igb/igb.h |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index 9e572dd..0c9f62c 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -131,9 +131,9 @@ struct vf_data_storage {
>  #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
>  
>  /* Supported Rx Buffer Sizes */
> -#define IGB_RXBUFFER_512   512
> +#define IGB_RXBUFFER_256   256
>  #define IGB_RXBUFFER_16384 16384
> -#define IGB_RX_HDR_LEN     IGB_RXBUFFER_512
> +#define IGB_RX_HDR_LEN     IGB_RXBUFFER_256
>  
>  /* How many Tx Descriptors do we need to call netif_wake_queue ? */
>  #define IGB_TX_QUEUE_WAKE	16
>
>
Would there be any problems with us running this through Jeff's tree for
testing prior to applying this?  I'm just wanting to do some testing
internally for any performance regressions due to this change.

Thanks,

Alex
