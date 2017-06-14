From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use skb_unref() in napi_consume_skb()
Date: Wed, 14 Jun 2017 15:24:39 -0400 (EDT)
Message-ID: <20170614.152439.51417607232018671.davem@davemloft.net>
References: <3425d279c75e1470cfa55ceb6a13a22019910de7.1497428844.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54168 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdFNTYm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:24:42 -0400
In-Reply-To: <3425d279c75e1470cfa55ceb6a13a22019910de7.1497428844.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 14 Jun 2017 11:48:48 +0200

> The commit 83ada39bb79d ("net: factor out a helper to decrement the
> skb refcount") provided and used a helper for decrementing skb usage,
> but I missed at least a spot for it.
> 
> This change remove some more duplicated code reusing skb_unref() in
> napi_consume_skb(), too. The helper uses an additional, unneeded
> unlikely(!skb) test - napi_consume_skb() already check it a few lines
> above - but the compiler is smart enough to optimize the duplicated
> test out.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
