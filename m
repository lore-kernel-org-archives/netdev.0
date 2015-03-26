From: Petri Gynther <pgynther@google.com>
Subject: Re: [PATCH net-next 4/7] net: bcmgenet: tweak init_umac()
Date: Thu, 26 Mar 2015 10:50:42 -0700
Message-ID: <CAGXr9JHUYEuAxC+Ur55n+SxXaP5-kzaMR0hKF6k=g0Nv7XLWoA@mail.gmail.com>
References: <20150325193513.08B462201FB@puck.mtv.corp.google.com>
	<5513356D.1000302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:33466 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbbCZRvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 13:51:07 -0400
Received: by qgfa8 with SMTP id a8so102928187qgf.0
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 10:51:06 -0700 (PDT)
In-Reply-To: <5513356D.1000302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Wed, Mar 25, 2015 at 3:23 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 25/03/15 12:35, Petri Gynther wrote:
>> Use more meaningful variable names int0_enable and int1_enable when
>> enabling bcmgenet interrupts.
>>
>> For Rx default queue interrupts, use:
>> UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE
>>
>> For Tx default queue interrupts, use:
>> UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE
>
> Can we define a constant for these two, kind of like what I did earlier
> with UMAC_IRQ_RXDMA_MASK and UMAC_IRQ_TXDMA_MASK?
>
> Does not need to happen now, but it could make the code clearer.
>

After this patch set is applied, I'll craft a patch for:
#define UMAC_IRQ_RXDMA_DONE  (UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE)
#define UMAC_IRQ_TXDMA_DONE  (UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE)

>>
>> Signed-off-by: Petri Gynther <pgynther@google.com>
>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> --
> Florian
