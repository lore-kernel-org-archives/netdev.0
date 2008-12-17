From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v2.6.29 v2 1/5] gianfar: Fix skb allocation error
Date: Wed, 17 Dec 2008 15:41:09 -0600
Message-ID: <47F56387-69C8-4537-AA3E-6EAC22CFBDFE@freescale.com>
References: <1229539981-14041-1-git-send-email-afleming@freescale.com> <1229539981-14041-2-git-send-email-afleming@freescale.com> <20081217.122252.267759802.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:59100 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbYLQVlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 16:41:19 -0500
In-Reply-To: <20081217.122252.267759802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 17, 2008, at 2:22 PM, David Miller wrote:

> From: Andy Fleming <afleming@freescale.com>
> Date: Wed, 17 Dec 2008 12:52:57 -0600
>
>> We don't want to unmap the skb if we've decided to use the old one,  
>> so we only
>> unmap it if we're *not* using the old one.
>>
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>
> Andy.... look at what you're doing here.  Your patch talks about DMA
> mapping, yet the patch deals with protecting an SKB free call.
>
> Your commit message matches the original patch but not this one.
>
> In fact I fear that, in fact, there was a bug being fixed originally,
> and in fact you do need to modify where the DMA unmap occurs in this
> function, but in fixing up the patch to apply you've not gotten that
> part straight.
>
> I'm tossing these patches again.  If the commit message can't even
> match what the patch is doing, you need to take a good long look at
> these changes and then resubmit them with accurate commit messages.

Argh, I apologize.  The patch still does the same thing, but the  
dma_unmap got moved up.  The commit message got hastily composed when  
I had to reapply the patch on an older tree, and I forgot to change it  
when I fixed it.  I will review and make sure I haven't made more such  
mistakes.

Andy
