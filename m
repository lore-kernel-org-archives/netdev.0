From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V5 0/3] vhost_net tx batching
Date: Wed, 18 Jan 2017 16:35:51 -0500 (EST)
Message-ID: <20170118.163551.1438116039860355723.davem@davemloft.net>
References: <1484722923-7698-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org, kvm@vger.kernel.org,
        stephen@networkplumber.org, wexu@redhat.com, stefanha@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751625AbdARViQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 16:38:16 -0500
In-Reply-To: <1484722923-7698-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 18 Jan 2017 15:02:00 +0800

> This series tries to implement tx batching support for vhost. This was
> done by using MSG_MORE as a hint for under layer socket. The backend
> (e.g tap) can then batch the packets temporarily in a list and
> submit it all once the number of bacthed exceeds a limitation.
> 
> Tests shows obvious improvement on guest pktgen over over
> mlx4(noqueue) on host:
 ...

Series applied, thanks Jason.
