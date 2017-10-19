From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] macvlan/macvtap: Add support for L2
 forwarding offloads with macvtap
Date: Thu, 19 Oct 2017 12:44:24 +0100 (WEST)
Message-ID: <20171019.124424.463288330485082808.davem@davemloft.net>
References: <20171017024428.28589.73728.stgit@ahduyck-green-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752132AbdJSLpj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 07:45:39 -0400
In-Reply-To: <20171017024428.28589.73728.stgit@ahduyck-green-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 16 Oct 2017 22:44:44 -0400

> This patch reverts earlier commit b13ba1b83f52 ("macvlan: forbid L2
> fowarding offload for macvtap"). The reason for reverting this is because
> the original patch no longer fixes what it previously did as the
> underlying structure has changed for macvtap. Specifically macvtap
> originally pulled packets directly off of the lowerdev. However in commit
> 6acf54f1cf0a ("macvtap: Add support of packet capture on macvtap device.")
> that code was changed and instead macvtap would listen directly on the
> macvtap device itself instead of the lower device. As such, the L2
> forwarding offload should now be able to provide a performance advantage of
> skipping the checks on the lower dev while not introducing any sort of
> regression.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
