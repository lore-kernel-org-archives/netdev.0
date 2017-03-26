From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] irda: vlsi_ir: fix check for dma mapping errors
Date: Sat, 25 Mar 2017 20:14:59 -0700 (PDT)
Message-ID: <20170325.201459.415344501888164456.davem@davemloft.net>
References: <1490395688-3666-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490395688-3666-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 25 Mar 2017 01:48:08 +0300

> vlsi_alloc_ring() checks for dma mapping errors by comparison
> returned address with zero, while pci_dma_mapping_error() should be used.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied.
