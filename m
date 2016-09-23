From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 05/11] skbuff: Extend gso_type to unsigned int.
Date: Fri, 23 Sep 2016 13:19:46 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0107FC2@AcuExch.aculab.com>
References: <1474617228-26103-1-git-send-email-steffen.klassert@secunet.com>
 <1474617228-26103-6-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>,
        "Hay, Joshua A" <joshua.a.hay@intel.com>
To: 'Steffen Klassert' <steffen.klassert@secunet.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:63087 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758238AbcIWNWe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 09:22:34 -0400
In-Reply-To: <1474617228-26103-6-git-send-email-steffen.klassert@secunet.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert
> Sent: 23 September 2016 08:54
> All available gso_type flags are currently in use,
> so extend gso_type to be able to add further flags.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  include/linux/skbuff.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index f21da42..c1fd854 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -417,7 +417,7 @@ struct skb_shared_info {
>  	unsigned short	gso_size;
>  	/* Warning: this field is not always filled in (UFO)! */
>  	unsigned short	gso_segs;
> -	unsigned short  gso_type;
> +	unsigned int	gso_type;
>  	struct sk_buff	*frag_list;
>  	struct skb_shared_hwtstamps hwtstamps;
>  	u32		tskey;

That add a lot of padding.
I'm not even sure DM will like this structure being extended.
If ktime_t is 64 bit I think there is already some padding later on.

	David
