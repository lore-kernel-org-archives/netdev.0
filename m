From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 4/7] net: bcmgenet: tweak init_umac()
Date: Wed, 25 Mar 2015 15:23:41 -0700
Message-ID: <5513356D.1000302@gmail.com>
References: <20150325193513.08B462201FB@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jaedon.shin@gmail.com
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:32977 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbbCYWYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 18:24:24 -0400
Received: by pdnc3 with SMTP id c3so42217790pdn.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 15:24:24 -0700 (PDT)
In-Reply-To: <20150325193513.08B462201FB@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/15 12:35, Petri Gynther wrote:
> Use more meaningful variable names int0_enable and int1_enable when
> enabling bcmgenet interrupts.
> 
> For Rx default queue interrupts, use:
> UMAC_IRQ_RXDMA_BDONE | UMAC_IRQ_RXDMA_PDONE
> 
> For Tx default queue interrupts, use:
> UMAC_IRQ_TXDMA_BDONE | UMAC_IRQ_TXDMA_PDONE

Can we define a constant for these two, kind of like what I did earlier
with UMAC_IRQ_RXDMA_MASK and UMAC_IRQ_TXDMA_MASK?

Does not need to happen now, but it could make the code clearer.

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
