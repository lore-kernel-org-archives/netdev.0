From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] sh_eth: Fix dma mapping issue
Date: Tue, 25 Nov 2014 23:07:56 +0300
Message-ID: <5474E19C.1020108@cogentembedded.com>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com> <1415862301-28032-4-git-send-email-ykaneko0929@gmail.com> <54653948.5070606@cogentembedded.com> <20141117040935.GA10017@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20141117040935.GA10017@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/17/2014 07:09 AM, Simon Horman wrote:

>>> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

>>> When CONFIG_DMA_API_DEBUG=y, many DMA error messages reports.
>>> In order to use DMA debug, This patch fix following issues.

>>> Issue 1:
>>> If dma_mapping_error function is not called appropriately after
>>> DMA mapping, DMA debug will report error message when DMA unmap
>>> function is called.

>>> Issue 2:
>>> If skb_reserve function is called after DMA mapping, the relationship
>>> between mapping addr and mapping size will be broken.
>>> In this case, DMA debug will report error messages when DMA sync
>>> function and DMA unmap function are called.

>>> Issue 3:
>>> If the size of frame data is less than ETH_ZLEN, the size is resized
>>> to ETH_ZLEN after DMA map function is called.
>>> In the TX skb freeing function, dma unmap function is called with that
>>> resized value. So, unmap size error will reported.

>>> Issue 4:
>>> In the rx function, DMA map function is called without DMA unmap function
>>> is called for RX skb reallocating.
>>> It will case the DMA debug error that number of debug entry is full and
>>> DMA debug logic is stopped.

>>     The rule of thumb is "fix one issue per patch". Please split accordingly.

>>> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
>>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

>>     Thanks for beating me to it. Fixing these issues has been on my agenda
>> for a long time... :-)

> as this patch is somewhat involved and as you have pointed out needs a bit
> of work I'm wondering if you could take it over.

    Perhaps I could... but I'm busy with other stuff... not sure when can I 
get to it.

[...]

WBR, Sergei

