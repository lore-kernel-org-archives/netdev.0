From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bpf: devmap: remove unnecessary value size
 check
Date: Wed, 16 Aug 2017 11:35:34 -0700 (PDT)
Message-ID: <20170816.113534.473760745011942655.davem@davemloft.net>
References: <20170816063512.14925.40390.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751772AbdHPSfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 14:35:34 -0400
In-Reply-To: <20170816063512.14925.40390.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 15 Aug 2017 23:35:12 -0700

> In the devmap alloc map logic we check to ensure that the sizeof the
> values are not greater than KMALLOC_MAX_SIZE. But, in the dev map case
> we ensure the value size is 4bytes earlier in the function because all
> values should be netdev ifindex values.
> 
> The second check is harmless but is not needed so remove it.
> 
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Applied.
