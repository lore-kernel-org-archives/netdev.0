From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/utils: generic inet_pton_with_scope helper
Date: Thu, 30 Mar 2017 12:40:07 -0700 (PDT)
Message-ID: <20170330.124007.1065811391753224581.davem@davemloft.net>
References: <1490809724-25234-1-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-nvme@lists.infradead.org, hch@lst.de
To: sagi@grimberg.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934238AbdC3TkJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 15:40:09 -0400
In-Reply-To: <1490809724-25234-1-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sagi Grimberg <sagi@grimberg.me>
Date: Wed, 29 Mar 2017 20:48:44 +0300

> Several locations in the stack need to handle ipv4/ipv6
> (with scope) and port strings conversion to sockaddr.
> Add a helper that takes either AF_INET, AF_INET6 or
> AF_UNSPEC (for wildcard) to centralize this handling.
> 
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Sagi Grimberg <sagi@grimberg.me>

This looks fine to me:

Acked-by: David S. Miller <davem@davemloft.net>
