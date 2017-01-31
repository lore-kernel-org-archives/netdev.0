From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 01/10] bnxt_en: Refactor rx SKB function.
Date: Mon, 30 Jan 2017 20:26:43 -0800
Message-ID: <20170130202643.5c0130ad@cakuba>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
        <1485827375-20421-2-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:30087 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750764AbdAaExp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 23:53:45 -0500
In-Reply-To: <1485827375-20421-2-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jan 2017 20:49:26 -0500, Michael Chan wrote:
> @@ -776,7 +778,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
>  	}
>  
>  	skb_reserve(skb, BNXT_RX_OFFSET);
> -	skb_put(skb, len);
> +	skb_put(skb, len & 0xffff);
>  	return skb;
>  }

Looks unrelated?
