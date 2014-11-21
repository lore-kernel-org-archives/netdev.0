From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] drivers: atm: eni: Add pci_dma_mapping_error() call
Date: Fri, 21 Nov 2014 15:03:54 -0500 (EST)
Message-ID: <20141121.150354.242152731394048793.davem@davemloft.net>
References: <1416479094-7764-1-git-send-email-tinajohnson.1234@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	julia.lawall@lip6.fr
To: tinajohnson.1234@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416479094-7764-1-git-send-email-tinajohnson.1234@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tina Johnson <tinajohnson.1234@gmail.com>
Date: Thu, 20 Nov 2014 15:54:54 +0530

> Added a pci_dma_mapping_error() call to check for mapping errors before
> further using the dma handle. In case of error, control goes to a new label
> where the incoming skb is freed. Unchecked dma handles were found using
> Coccinelle:
> 
> @rule1@
> expression e1;
> identifier x;
> @@
> 
> *x = pci_map_single(...);
>  ... when != pci_dma_mapping_error(e1,x)
> 
> Signed-off-by: Tina Johnson <tinajohnson.1234@gmail.com>
> Acked-by: Julia Lawall <julia.lawall@lip6.fr>
> ---
> v2: *Removed jump to trouble label
>     *Added a new label dma_map_error

Applied, thanks.
