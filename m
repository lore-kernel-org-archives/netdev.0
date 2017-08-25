From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next v2] tg3: Be drop monitor friendly
Date: Thu, 24 Aug 2017 17:50:16 -0700
Message-ID: <CACKFLimXqzgpKRnPLjxyCUiyEDCYhNScp1qq1rv9gVWWZKGzBA@mail.gmail.com>
References: <20170825004711.19793-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, edumazet@gmail.com,
        Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825004711.19793-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2017 at 5:47 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> tg3_tx() does the normal packet TX completion,
> tigon3_dma_hwbug_workaround() and tg3_tso_bug() both need to allocate a
> new SKB that is suitable to workaround HW bugs, and finally
> tg3_free_rings() is doing ring cleanup. Use dev_consume_skb_any() for
> these 3 locations to be SKB drop monitor friendly.
>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>

> ---
> Changes in v2:
>
> - also included tg3_tso_bug() as indicated by Michael
>
