From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] gianfar: prevent fragmentation in DSA environments
Date: Tue, 23 Aug 2016 16:49:20 -0700 (PDT)
Message-ID: <20160823.164920.891958713604067093.davem@davemloft.net>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
        <1471874198-15321-1-git-send-email-zefir.kurtisi@neratec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
        andrew@lunn.ch
To: zefir.kurtisi@neratec.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55831 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753311AbcHWXtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:49:21 -0400
In-Reply-To: <1471874198-15321-1-git-send-email-zefir.kurtisi@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Date: Mon, 22 Aug 2016 15:56:38 +0200

> The eTSEC register MRBLR defines the maximum space in
> the RX buffers and is set to 1536 by gianfar. This
> reasonably covers the common use case where the MTU
> is kept at default 1500. In that case, the largest
> Ethernet frame size of 1518 plus an optional
> GMAC_FCB_LEN of 8, and an additional padding of 8
> to handle FSL_GIANFAR_DEV_HAS_TIMER totals to 1534
> and nicely fit within the chosen MRBLR.
> 
> Alas, if the eTSEC is attached to a DSA enabled switch,
> the (E)DSA header extension (4 or 8 bytes) causes every
> maximum sized frame to be fragmented by the hardware.
> 
> This patch increases the maximum RX buffer size by 8
> and rounds up to the next multiple of 64, which the
> hardware's defines as RX buffer granularity.
> 
> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>

Applied.
