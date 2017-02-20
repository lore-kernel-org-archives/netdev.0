From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1] macsec: fix validation failed in
 asynchronous operation.
Date: Mon, 20 Feb 2017 09:55:54 -0500 (EST)
Message-ID: <20170220.095554.369235627490818017.davem@davemloft.net>
References: <1487586750-38377-1-git-send-email-ryder.lee@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: ryder.lee@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37894 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750872AbdBTOz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 09:55:56 -0500
In-Reply-To: <1487586750-38377-1-git-send-email-ryder.lee@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ryder Lee <ryder.lee@mediatek.com>
Date: Mon, 20 Feb 2017 18:32:30 +0800

> @@ -879,6 +879,9 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
>  
>  	aead_request_free(macsec_skb_cb(skb)->req);
>  
> +	if (err == 0)
> +	 macsec_skb_cb(skb)->valid = true;
> +

This is not indented properly, please use TABs like the rest of
the code does.  And the canonical way to test against zero is
"if (!err)"
