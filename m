From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] virtio-net: correctly enable multiqueue
Date: Tue, 13 Dec 2016 10:39:57 -0500 (EST)
Message-ID: <20161213.103957.237216716208627704.davem@davemloft.net>
References: <1481610185-12183-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        tytso@mit.edu, nhorman@tuxdriver.com, mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932346AbcLMPkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 10:40:06 -0500
In-Reply-To: <1481610185-12183-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 13 Dec 2016 14:23:05 +0800

> Commit 4490001029012539937ff02778fe6180613fa949 ("virtio-net: enable
> multiqueue by default") blindly set the affinity instead of queues
> during probe which can cause a mismatch of #queues between guest and
> host. This patch fixes it by setting queues.
> 
> Reported-by: Theodore Ts'o <tytso@mit.edu>
> Tested-by: Theodore Ts'o <tytso@mit.edu>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Fixes: 49000102901 ("virtio-net: enable multiqueue by default")
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
