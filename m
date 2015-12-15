From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: fix descriptor access endianness
Date: Tue, 15 Dec 2015 14:26:51 +0300
Message-ID: <566FF8FB.2010005@cogentembedded.com>
References: <11070795.yxBPvlHg4n@wasted.cogentembedded.com>
 <20151215.002541.762812772082527155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20151215.002541.762812772082527155.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/15/2015 8:25 AM, David Miller wrote:

>> The driver never  calls cpu_to_edmac() when writing the descriptor address
>> and edmac_to_cpu() when reading it, although it should -- fix this.
>>
>> Note that the frame/buffer length descriptor field accesses also need fixing
>> but since they are both 16-bit we can't  use {cpu|edmac}_to_{edmac|cpu}()...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>
> Applied.

    I was going to rework this to fix _all_ cases, and sent follow-up email 
about that yesterday... Haven't you received it?

MBR, Sergei

