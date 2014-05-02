From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH] Altera TSE: ALTERA_TSE should depend on HAS_DMA
Date: Fri, 2 May 2014 10:41:26 -0500
Message-ID: <CAOwfj2O+A1Tg-pMhgYo9yDVRWVhQV86UD2fdidbVXpaN_+5J9g@mail.gmail.com>
References: <1399004962-19530-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1399004962-19530-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 1, 2014 at 11:29 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> If NO_DMA=y:
>
> drivers/built-in.o: In function `altera_tse_probe':
> altera_tse_main.c:(.text+0x25ec2e): undefined reference to `dma_set_mask'
> altera_tse_main.c:(.text+0x25ec78): undefined reference to `dma_supported'
> altera_tse_main.c:(.text+0x25ecb6): undefined reference to `dma_supported'
> drivers/built-in.o: In function `sgdma_async_read':
> altera_sgdma.c:(.text+0x25f620): undefined reference to `dma_sync_single_for_cpu'
> drivers/built-in.o: In function `sgdma_uninitialize':
> (.text+0x25f678): undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `sgdma_uninitialize':
> (.text+0x25f696): undefined reference to `dma_unmap_single'
> drivers/built-in.o: In function `sgdma_initialize':
> (.text+0x25f6f0): undefined reference to `dma_map_single'
> drivers/built-in.o: In function `sgdma_initialize':
> (.text+0x25f702): undefined reference to `dma_mapping_error'
> drivers/built-in.o: In function `sgdma_tx_buffer':
> (.text+0x25f92a): undefined reference to `dma_sync_single_for_cpu'
> drivers/built-in.o: In function `sgdma_rx_status':
> (.text+0x25fa24): undefined reference to `dma_sync_single_for_cpu'
> make[3]: *** [vmlinux] Error 1
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---

Acked-by: Vince Bridgers <vbridgers2013@gmail.com>

Thanks Geert,

Vince
