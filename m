From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v9 net-next] ravb: Add dma queue interrupt support
Date: Mon, 04 Apr 2016 16:02:24 -0400 (EDT)
Message-ID: <20160404.160224.63334418160687731.davem@davemloft.net>
References: <1459695278-24142-1-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	horms@verge.net.au, magnus.damm@gmail.com,
	linux-renesas-soc@vger.kernel.org
To: ykaneko0929@gmail.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1459695278-24142-1-git-send-email-ykaneko0929@gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Date: Sun,  3 Apr 2016 23:54:38 +0900

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> 
> This patch supports the following interrupts.
> 
> - One interrupt for multiple (timestamp, error, gPTP)
> - One interrupt for emac
> - Four interrupts for dma queue (best effort rx/tx, network control rx/tx)
> 
> This patch improve efficiency of the interrupt handler by adding the
> interrupt handler corresponding to each interrupt source described
> above. Additionally, it reduces the number of times of the access to
> EthernetAVB IF.
> Also this patch prevent this driver depends on the whim of a boot loader.
> 
> [ykaneko0929@gmail.com: define bit names of registers]
> [ykaneko0929@gmail.com: add comment for gen3 only registers]
> [ykaneko0929@gmail.com: fix coding style]
> [ykaneko0929@gmail.com: update changelog]
> [ykaneko0929@gmail.com: gen3: fix initialization of interrupts]
> [ykaneko0929@gmail.com: gen3: fix clearing interrupts]
> [ykaneko0929@gmail.com: gen3: add helper function for request_irq()]
> [ykaneko0929@gmail.com: gen3: remove IRQF_SHARED flag for request_irq()]
> [ykaneko0929@gmail.com: revert ravb_close() and ravb_ptp_stop()]
> [ykaneko0929@gmail.com: avoid calling free_irq() to non-hooked interrupts]
> [ykaneko0929@gmail.com: make NC/BE interrupt handler a function]
> [ykaneko0929@gmail.com: make timestamp interrupt handler a function]
> [ykaneko0929@gmail.com: timestamp interrupt is handled in multiple
>  interrupt handler instead of dma queue interrupt handler]
> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
