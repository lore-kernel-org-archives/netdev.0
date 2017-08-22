From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3 v7] net: ether: Add support for multiplexing
 and aggregation type
Date: Tue, 22 Aug 2017 03:02:08 +0200
Message-ID: <20170822010208.GA24555@lunn.ch>
References: <1503355019-12236-1-git-send-email-subashab@codeaurora.org>
 <1503355019-12236-2-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, dcbw@redhat.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38562 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754252AbdHVBCU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 21:02:20 -0400
Content-Disposition: inline
In-Reply-To: <1503355019-12236-2-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 04:36:57PM -0600, Subash Abhinov Kasiviswanathan wrote:
> Define the multiplexing and aggregation (MAP) ether type 0xDA1A. This
> is needed for receiving data in the MAP protocol like RMNET. This is
> not an officially registered ID.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  include/uapi/linux/if_ether.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
> index 5bc9bfd..e80b03f 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -104,7 +104,9 @@
>  #define ETH_P_QINQ3	0x9300		/* deprecated QinQ VLAN [ NOT AN OFFICIALLY REGISTERED ID ] */
>  #define ETH_P_EDSA	0xDADA		/* Ethertype DSA [ NOT AN OFFICIALLY REGISTERED ID ] */
>  #define ETH_P_AF_IUCV   0xFBFB		/* IBM af_iucv [ NOT AN OFFICIALLY REGISTERED ID ] */
> -
> +#define ETH_P_MAP       0xDA1A          /* Multiplexing and Aggregation Protocol
> +					 *  NOT AN OFFICIALLY REGISTERED ID ]
> +					 */

Hi Subash

This list is sorted. So this entry should go earlier.

     Andrew
