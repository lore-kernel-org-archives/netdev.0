From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH net-next 1/3 v9] net: ether: Add support for
 multiplexing and aggregation type
Date: Mon, 28 Aug 2017 17:22:33 -0500
Message-ID: <1503958953.20027.5.camel@redhat.com>
References: <1503635966-14076-1-git-send-email-subashab@codeaurora.org>
         <1503635966-14076-2-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com, jiri@resnulli.us,
        stephen@networkplumber.org, David.Laight@ACULAB.COM,
        marcel@holtmann.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39152 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751213AbdH1WYq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 18:24:46 -0400
In-Reply-To: <1503635966-14076-2-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-08-24 at 22:39 -0600, Subash Abhinov Kasiviswanathan
wrote:
> Define the multiplexing and aggregation (MAP) ether type 0x00F9. This
> is needed for receiving data in the MAP protocol like RMNET. This is
> not an officially registered ID.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.or
> g>
> ---
>  include/uapi/linux/if_ether.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/uapi/linux/if_ether.h
> b/include/uapi/linux/if_ether.h
> index 5bc9bfd..0d73ecc 100644
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -137,6 +137,7 @@
>  #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame
> 		*/
>  #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF
> protocol	*/
>  #define ETH_P_XDSA	0x00F8		/* Multiplexed DSA
> protocol	*/
> +#define ETH_P_MAP	0x00F9		/* Multiplex &
> aggregation proto*/

Any chance you could name this QUALCOMM_MAP or something like that?  Or
at least update the comment to include that fact.

Dan

>  /*
>   *	This is an Ethernet frame header.
