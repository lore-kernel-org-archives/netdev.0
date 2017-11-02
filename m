From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bpf: cpumap micro-optimization in
 cpu_map_enqueue
Date: Thu, 02 Nov 2017 16:14:35 +0900 (KST)
Message-ID: <20171102.161435.1119634915876878060.davem@davemloft.net>
References: <150953668583.30172.5069550217700139382.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44182 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751567AbdKBHOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:14:38 -0400
In-Reply-To: <150953668583.30172.5069550217700139382.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 01 Nov 2017 12:44:45 +0100

> Discovered that the compiler laid-out asm code in suboptimal way
> when studying perf report during benchmarking of cpumap. Help
> the compiler by the marking unlikely code paths.
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.
