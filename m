From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tuntap: remove unnecessary sk_receive_queue
 length check during xmit
Date: Thu, 24 Nov 2016 16:07:19 -0500 (EST)
Message-ID: <20161124.160719.645523357072527584.davem@davemloft.net>
References: <1479868009-14157-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966250AbcKXVHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:07:41 -0500
In-Reply-To: <1479868009-14157-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 23 Nov 2016 10:26:49 +0800

> After commit 1576d9860599 ("tun: switch to use skb array for tx"),
> sk_receive_queue was not used any more. So remove the uncessary
> sk_receive_queue length check during xmit.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Good catch, applied, thanks Jason.
