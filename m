From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: fix WARNING in dma_free_coherent()
Date: Fri, 30 Oct 2015 02:11:08 +0300
Message-ID: <5632A78C.4090807@cogentembedded.com>
References: <5844359.Wmo6777QiE@wasted.cogentembedded.com>
 <1503970.kr1SvaSeoy@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1503970.kr1SvaSeoy@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/30/2015 12:52 AM, Sergei Shtylyov wrote:

> Iff the first dma_alloc_coherent()  call fails in sh_eth_ring_init(), the
> following  is printed to the kernel console:
>
> WARNING: CPU: 0 PID: 1 at drivers/base/dma-mapping.c:334 dma_common_free_remap+0x48/0x6c()

    Oops, I got the function name wrong in the subject. David, can you fix 
this while applying or should I repost?

MBR, Sergei

