From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: Re: [PATCH] mac80211: add doc for RX_FLAG_DUP_VALIDATED flag
Date: Fri, 18 Mar 2016 18:54:34 +0000
Message-ID: <56EC4EEA.8040201@osg.samsung.com>
References: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:54713 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbcCRSyj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 14:54:39 -0400
In-Reply-To: <1458317369-28185-1-git-send-email-luisbg@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/16 16:09, Luis de Bethencourt wrote:
> Add documentation for the flag for duplication check.
> 
> Fixes the following warning when running make htmldocs:
> warning: Enum value 'RX_FLAG_DUP_VALIDATED' not described in enum 'mac80211_rx_flags'
> 
> Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
> ---
> Hi,
> 
> While running make htmldocs I noticed a warning about RX_FLAG_DUP_VALIDATED
> missing a description. This patch fixes this.
> 
> I have noticed the order of the descriptions of the mac80211_rx_flags doesn't
> match the order in the enum. I am happy to fix this if it would be of interest.
> 
> Thanks,
> Luis
> 
>  include/net/mac80211.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/net/mac80211.h b/include/net/mac80211.h
> index a53333c..42c8cde 100644
> --- a/include/net/mac80211.h
> +++ b/include/net/mac80211.h
> @@ -1001,6 +1001,8 @@ ieee80211_tx_info_clear_status(struct ieee80211_tx_info *info)
>   *	flag indicates that the PN was verified for replay protection.
>   *	Note that this flag is also currently only supported when a frame
>   *	is also decrypted (ie. @RX_FLAG_DECRYPTED must be set)
> + * @RX_FLAG_DUP_VALIDATED: Set this flag for the driver to check for packet
> + *	duplication by itself.
>   * @RX_FLAG_FAILED_FCS_CRC: Set this flag if the FCS check failed on
>   *	the frame.
>   * @RX_FLAG_FAILED_PLCP_CRC: Set this flag if the PCLP check failed on
> 

Please ignore the second patch I replied to this one. It is wrong due to my
misunderstanding.

This above patch adding RX_FLAG_DUP_VALIDATED is correct and I believe it to be
valid.

Thanks for the reviews,
Luis
