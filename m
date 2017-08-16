From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next 2/3 v4] net: arp: Add support for raw IP device
Date: Wed, 16 Aug 2017 06:52:41 +0200
Message-ID: <7D61C5CD-5B75-46C8-AC00-C4852FC1A554@holtmann.org>
References: <1502856953-30321-1-git-send-email-subashab@codeaurora.org>
 <1502856953-30321-3-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev list <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>, fengguang.wu@intel.com,
        Dan Williams <dcbw@redhat.com>, jiri@resnulli.us,
        stephen@networkplumber.org
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:46984 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbdHPEwo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 00:52:44 -0400
In-Reply-To: <1502856953-30321-3-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Subash,

> Define the raw IP type. This is needed for raw IP net devices
> like rmnet.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
> include/uapi/linux/if_arp.h | 1 +
> 1 file changed, 1 insertion(+)
> 
> diff --git a/include/uapi/linux/if_arp.h b/include/uapi/linux/if_arp.h
> index cf73510..d6650e2 100644
> --- a/include/uapi/linux/if_arp.h
> +++ b/include/uapi/linux/if_arp.h
> @@ -59,6 +59,7 @@
> #define ARPHRD_LAPB	516		/* LAPB				*/
> #define ARPHRD_DDCMP    517		/* Digital's DDCMP protocol     */
> #define ARPHRD_RAWHDLC	518		/* Raw HDLC			*/
> +#define ARPHRD_RAWIP    530             /* Raw IP                       */

what is up with gap here?

Regards

Marcel
