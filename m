From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix pf2vf bulletin DMA mapping leak
Date: Wed, 07 Jun 2017 13:00:07 -0400 (EDT)
Message-ID: <20170607.130007.1839073058944496532.davem@davemloft.net>
References: <20170606143031.863-1-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60104 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751677AbdFGRAJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 13:00:09 -0400
In-Reply-To: <20170606143031.863-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Tue,  6 Jun 2017 16:30:31 +0200

> When freeing VF's DMA mappings, an already NULLed pointer was checked
> again due to an apparent copy&paste error. Consequently, the pf2vf
> bulletin DMA mapping was not freed.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thank you.
