From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] tg3: Be drop monitor friendly
Date: Thu, 24 Aug 2017 17:42:36 -0700
Message-ID: <88bf2189-a867-897c-d030-7a025d48782f@gmail.com>
References: <20170824232530.16728-1-f.fainelli@gmail.com>
 <CACKFLi=a0KaETnnObmWesxyaqt2DrvbsaKPAGXrE-NawcQyB_A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Netdev <netdev@vger.kernel.org>, edumazet@gmail.com,
        David Miller <davem@davemloft.net>,
        Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        open list <linux-kernel@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACKFLi=a0KaETnnObmWesxyaqt2DrvbsaKPAGXrE-NawcQyB_A@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/24/2017 05:04 PM, Michael Chan wrote:
> On Thu, Aug 24, 2017 at 4:25 PM, Florian Fainelli <f.fainelli@gmail.com
> <mailto:f.fainelli@gmail.com>> wrote:
>>
>> tg3_tx() does the normal packet TX completion,
>> tigon3_dma_hwbug_workaround() needs to allocate a new SKB that is
>> suitable for the DMA hardware bug, and finally tg3_free_rings() is doing
>> ring cleanup. Use dev_consume_skb_any() for these 3 locations to be SKB
>> drop monitor friendly.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com
> <mailto:f.fainelli@gmail.com>>
> 
> Florian, the one at the end of tg3_tso_bug() should also be converted to
> dev_consume_skb_any().  tg3_tso_bug() is similar to
> tigon3_dma_hwbug_workaround().  Thanks.

Indeed, thanks, will resubmit.
-- 
Florian
