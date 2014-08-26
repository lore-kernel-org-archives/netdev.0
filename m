From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 3/4] net: moxa: synchronize DMA memory
Date: Mon, 25 Aug 2014 17:26:10 -0700 (PDT)
Message-ID: <20140825.172610.496537032439062803.davem@davemloft.net>
References: <1408976552-15659-1-git-send-email-jonas.jensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	eric.dumazet@gmail.com, mirqus@gmail.com
To: jonas.jensen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408976552-15659-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jonas Jensen <jonas.jensen@gmail.com>
Date: Mon, 25 Aug 2014 16:22:32 +0200

> DMA memory should be synchronized before data is passed
> to/from controller.
> 
> Add dma_sync_single_for_cpu(.., DMA_FROM_DEVICE) to RX path
> and dma_sync_single_for_device(.., DMA_TO_DEVICE) to TX path.
> 
> Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>

Applied.
