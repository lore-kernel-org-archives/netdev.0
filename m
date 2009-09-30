From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: Remove prev_vlan_tag from struct tx_ring_info
Date: Wed, 30 Sep 2009 10:26:43 -0700
Message-ID: <20090930172643.GA14439@xw6200.broadcom.net>
References: <4AC36638.8070304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1281 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970AbZI3R0v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2009 13:26:51 -0400
In-Reply-To: <4AC36638.8070304@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 30, 2009 at 07:07:52AM -0700, Eric Dumazet wrote:
> prev_vlan_tag field is not used.
> 
> Patch saves 512*8 bytes per tx queue ring on 64bit arches.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good to me.

Acked-by: Matthew Carlson <mcarlson@broadcom.com>

> ---
> 
> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> index 82b45d8..524691c 100644
> --- a/drivers/net/tg3.h
> +++ b/drivers/net/tg3.h
> @@ -2412,7 +2412,6 @@ struct ring_info {
>  
>  struct tx_ring_info {
>  	struct sk_buff                  *skb;
> -	u32                             prev_vlan_tag;
>  };
>  
>  struct tg3_config_info {
> 

