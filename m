From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH RFC 09/14] net: wireless: mac80211: shrink private
 driver area
Date: Mon, 02 Mar 2015 19:52:53 +0100
Message-ID: <1425322373.1906.3.camel@sipsolutions.net>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
	 <1425318028-26531-10-git-send-email-fw@strlen.de>
	 (sfid-20150302_184214_486235_3C68A9D8)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51782 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037AbbCBSw6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 13:52:58 -0500
In-Reply-To: <1425318028-26531-10-git-send-email-fw@strlen.de> (sfid-20150302_184214_486235_3C68A9D8)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-02 at 18:40 +0100, Florian Westphal wrote:
> This makes the structure fit 44-byte sized skb->cb[].
> 
> Cc: linux-wireless@vger.kernel.org
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  drivers/net/wireless/ath/ath9k/ath9k.h | 2 +-
>  include/net/mac80211.h                 | 8 +++-----
>  2 files changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
> index 0f8e946..2ed77cf 100644
> --- a/drivers/net/wireless/ath/ath9k/ath9k.h
> +++ b/drivers/net/wireless/ath/ath9k/ath9k.h

This is clearly not a mac80211 patch.

johannes
