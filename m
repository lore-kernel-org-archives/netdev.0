From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net] ravb: unmap descriptors when freeing rings
Date: Thu, 26 Jan 2017 18:42:03 -0500 (EST)
Message-ID: <20170126.184203.1144356525122970431.davem@davemloft.net>
References: <1485437367-3245-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        kazuya.mizuguchi.ks@renesas.com
To: horms+renesas@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52714 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752456AbdAZXu4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:50:56 -0500
In-Reply-To: <1485437367-3245-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms+renesas@verge.net.au>
Date: Thu, 26 Jan 2017 14:29:27 +0100

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> 
> "swiotlb buffer is full" errors occur after repeated initialisation of a
> device - f.e. suspend/resume or ip link set up/down. This is because memory
> mapped using dma_map_single() in ravb_ring_format() and ravb_start_xmit()
> is not released.  Resolve this problem by unmapping descriptors when
> freeing rings.
> 
> Fixes: c156633f1353 ("Renesas Ethernet AVB driver proper")
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> [simon: reworked]
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Applied, thanks Simon.
