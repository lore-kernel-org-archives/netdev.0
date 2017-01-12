From: Lino Sanfilippo <lsanfil@marvell.com>
Subject: Re: [EXT] Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when
 freeing rings
Date: Thu, 12 Jan 2017 17:55:29 +0100
Message-ID: <4950c7fd-dfe5-ea02-ba23-5477a0ba8e5e@marvell.com>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <d840eddd-f6a3-fe8c-dbaa-242c117b5274@marvell.com>
 <08e00682-a8da-1483-b2d8-f58d32587fd6@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, <netdev@vger.kernel.org>,
        <linux-renesas-soc@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <08e00682-a8da-1483-b2d8-f58d32587fd6@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 12.01.2017 17:37, Sergei Shtylyov wrote:
> External Email
>
> ----------------------------------------------------------------------
> On 01/12/2017 04:23 PM, Lino Sanfilippo wrote:
>
>>>>> +
>>>>> +    for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
>>
>> BTW: How can this work correctly when cur_tx wraps and dirty_tx is greater?
>
>    {cur|dirty}_tx never wrap.
>

Both values are 32 bit and AFAICS they are only incremented (and never reset or
decremented).
So what prevents them from wrapping every 2^32 processed tx descriptors? Am I missing
something?

Regards,
Lino
