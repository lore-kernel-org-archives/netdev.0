From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: remove unreachable ufo branches
Date: Tue, 22 Aug 2017 14:27:31 -0700 (PDT)
Message-ID: <20170822.142731.135728354340283890.davem@davemloft.net>
References: <20170822153957.99341-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44362 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752332AbdHVV1b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:27:31 -0400
In-Reply-To: <20170822153957.99341-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Tue, 22 Aug 2017 11:39:57 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Remove two references to ufo in the udp send path that are no longer
> reachable now that ufo has been removed.
> 
> Commit 85f1bd9a7b5a ("udp: consistently apply ufo or fragmentation")
> is a fix to ufo. It is safe to revert what remains of it.
> 
> Also, no skb can enter ip_append_page with skb_is_gso true now that
> skb_shinfo(skb)->gso_type is no longer set in ip_append_page/_data.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks for sorting this out.
