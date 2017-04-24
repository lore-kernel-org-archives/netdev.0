From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: core: Prevent from dereferencing null pointer
 when
Date: Mon, 24 Apr 2017 12:02:35 -0400 (EDT)
Message-ID: <20170424.120235.438297438450788048.davem@davemloft.net>
References: <1492732760-25081-1-git-send-email-mhjungk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: mhjungk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S972616AbdDXQCi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:02:38 -0400
In-Reply-To: <1492732760-25081-1-git-send-email-mhjungk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Myungho Jung <mhjungk@gmail.com>
Date: Thu, 20 Apr 2017 16:59:20 -0700

> Added NULL check to make __dev_kfree_skb_irq consistent with kfree
> family of functions.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289
> 
> Signed-off-by: Myungho Jung <mhjungk@gmail.com>
> ---
> Changes in v2:
>  - Correct category in subject

This subject line is an incomplete sentence.

This patch prevents dereferenccing a null pointer when "what"?
