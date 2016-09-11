From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Optimisation of fs_enet ethernet driver
Date: Sat, 10 Sep 2016 21:17:28 -0700 (PDT)
Message-ID: <20160910.211728.222777942734908576.davem@davemloft.net>
References: <cover.1473422536.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: christophe.leroy@c-s.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750934AbcIKER3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 00:17:29 -0400
In-Reply-To: <cover.1473422536.git.christophe.leroy@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christophe Leroy <christophe.leroy@c-s.fr>
Date: Fri,  9 Sep 2016 14:26:18 +0200 (CEST)

> This set optimises the freescale fs_enet ethernet driver:
> 1/ Merge of RX and TX NAPI functions in order to limit the amount of
> interrupts
> 2/ Do not unmap DMA when packets len is below copybreak, otherwise there
> is no benefit in copying the skb instead of allocating a new one
> 3/ Make copybreak value configurable as the optimised value is not the
> same on all targets

Series applied, thanks.
