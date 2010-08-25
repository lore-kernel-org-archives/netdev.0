From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] ll_temac: Fix poll implementation
Date: Wed, 25 Aug 2010 14:24:05 +0200
Message-ID: <4C750B65.4090309@monstr.eu>
References: <1282127194-4185-1-git-send-email-monstr@monstr.eu> <20100819.004845.148553935.davem@davemloft.net>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: glikely@secretlab.ca, netdev@vger.kernel.org, rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57871 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752013Ab0HYMYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 08:24:11 -0400
Received: by fxm13 with SMTP id 13so216535fxm.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 05:24:09 -0700 (PDT)
In-Reply-To: <20100819.004845.148553935.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Michal Simek <monstr@monstr.eu>
> Date: Wed, 18 Aug 2010 12:26:34 +0200
> 
>> Functions ll_temac_rx_irq and ll_temac_tx_irq
>> have pointer to net_device as second parameter not
>> pointer to temac_local.
>>
>> Signed-off-by: Michal Simek <monstr@monstr.eu>
> 
> Applied, thanks a lot.
> 
> I can't count how many times this kind of error has been
> introduced.  It's of cource because the handle passed to
> IRQ handlers is an opaque void pointer, so if the underlying
> type gets changed there is absolutely no type checking done
> against by-hand calls of the IRQ handler.
> 
> Rusty Russell was, if I remember correctly, doing some work
> to correct this such that IRQ handlers could in fact have
> some proper typing in their handlers.  Or maybe that was for
> timer handlers?
> 
> Anyways that kind of thing would help here.
> 
> Rusty?

Rusty, you there?

Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
