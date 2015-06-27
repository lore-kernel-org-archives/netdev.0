From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: Re: [PATCH] net: via: VIA_RHINE and VIA_VELOCITY should depend on HAS_DMA
Date: Sat, 27 Jun 2015 14:38:45 +0800
Message-ID: <CAAj6DX3VmUguq+rqyDWY0ezKmUuFe6-j0YZ8yv7He4JWyf4Ocw@mail.gmail.com>
References: <1435320502-4951-1-git-send-email-geert@linux-m68k.org>
	<558D51D4.9060202@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33131 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbbF0Giq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 02:38:46 -0400
In-Reply-To: <558D51D4.9060202@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2015 at 9:21 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 6/26/2015 3:08 PM, Geert Uytterhoeven wrote:
>
>> If NO_DMA=y:
>
>
>>      ERROR: "dma_sync_single_for_cpu"
>> [drivers/net/ethernet/via/via-rhine.ko] undefined!
>>      ERROR: "dma_set_mask" [drivers/net/ethernet/via/via-rhine.ko]
>> undefined!
>>      ERROR: "dma_mapping_error" [drivers/net/ethernet/via/via-rhine.ko]
>> undefined!
>>      ERROR: "dma_map_single" [drivers/net/ethernet/via/via-rhine.ko]
>> undefined!
>>      ERROR: "dma_alloc_coherent" [drivers/net/ethernet/via/via-rhine.ko]
>> undefined!
>>      ERROR: "dma_free_coherent" [drivers/net/ethernet/via/via-rhine.ko]
>> undefined!
>>      ERROR: "dma_unmap_single" [drivers/net/ethernet/via/via-rhine.ko]
>> undefined!
>>      ERROR: "dma_map_page" [drivers/net/ethernet/via/via-velocity.ko]
>> undefined!
>>      ERROR: "dma_sync_single_for_cpu"
>> [drivers/net/ethernet/via/via-velocity.ko] undefined!
>>      ERROR: "dma_free_coherent" [drivers/net/ethernet/via/via-velocity.ko]
>> undefined!
>>      ERROR: "dma_unmap_single" [drivers/net/ethernet/via/via-velocity.ko]
>> undefined!
>>      ERROR: "dma_map_single" [drivers/net/ethernet/via/via-velocity.ko]
>> undefined!
>>      ERROR: "dma_alloc_coherent"
>> [drivers/net/ethernet/via/via-velocity.ko] undefined!
>
>
>> Before, the symbols depended implicitly on HAS_DMA through PCI or
>> USE_OF.  Add explicit dependencies on HAS_DMA to fix this.
>
>
>> Fixes: commit b7d3282a245f4428 ("net: via/Kconfig: replace USE_OF with
>> OF_???")
>
>
> Fixes: b7d3282a245f ("net: via/Kconfig: replace USE_OF with OF_???")
>
>> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
>
>
> WBR, Sergei
>

Yes, I can confirm it.
If HAS_DMA is not defined the build is broken.
Your patch fixes the issue.

Thanks,
Antonio
