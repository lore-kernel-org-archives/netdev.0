From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] pxa168_eth: Allocate receive queue initialized to
 zero
Date: Wed, 19 Jun 2013 22:19:36 -0700 (PDT)
Message-ID: <20130619.221936.645815291796203336.davem@davemloft.net>
References: <1371576648-21632-1-git-send-email-lkundrak@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konszert@marvell.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lkundrak@v3.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371576648-21632-1-git-send-email-lkundrak@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Tue, 18 Jun 2013 19:30:48 +0200

> Zero pointer in rx_skb or tx_skb is how respective *_deinit() functions find
> out that a skb slot is unallocated. If *_init() functions unsuccessfully return
> after the allocation (e.g. when subsequent dma_alloc_coherent() is not
> successful), this would result in attempt to kfree() invalid pointers.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Applied.
