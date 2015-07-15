From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: do not invalidate cache for RX buffer twice
Date: Wed, 15 Jul 2015 15:11:07 +0300
Message-ID: <55A64DDB.4010108@cogentembedded.com>
References: <4759713.2ulGRKsd9L@wasted.cogentembedded.com>
 <55A639CE.2030201@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <55A639CE.2030201@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/15/2015 1:45 PM, Sergei Shtylyov wrote:

>> First, dma_sync_single_for_cpu() shouldn't have been called in the first place
>> (it's a streaming DMA API). dma_unmap_single() should have been called instead.
>                            ^
>     Oops, I meant comma here.

>> Second, dma_unmap_single() call after handing the buffer to napi_gro_receive()
>> makes little sense.

>     Moreover, 'desc->dptr' may not be valid at this point...

>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>> ---
>> The patch is against Dave Miller's 'net.git' repo.

>> Don't know why I missed this DMA API misuse while working on the driver. :-<

>     Dave, do you want me to resend the patch with fixed up changelog?

    Oops, forgot to CC Dave. :-(

WBR, Sergei

