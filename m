From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] macsec: fix validation failed in
 asynchronous operation.
Date: Tue, 21 Feb 2017 13:14:11 -0500 (EST)
Message-ID: <20170221.131411.2277956930369431131.davem@davemloft.net>
References: <1487670045-54641-1-git-send-email-ryder.lee@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sd@queasysnail.net, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org
To: ryder.lee@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55898 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753262AbdBUSON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:14:13 -0500
In-Reply-To: <1487670045-54641-1-git-send-email-ryder.lee@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ryder Lee <ryder.lee@mediatek.com>
Date: Tue, 21 Feb 2017 17:40:45 +0800

> MACSec test failed when asynchronous crypto operations is used. It
> encounters packet validation failed since macsec_skb_cb(skb)->valid
> is always 'false'.
> 
> This patch adds missing "macsec_skb_cb(skb)->valid = true" in
> macsec_decrypt_done() when "err == 0".
> 
> Signed-off-by: Ryder Lee <ryder.lee@mediatek.com>

Applied, thanks.
