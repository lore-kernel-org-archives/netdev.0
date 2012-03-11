From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 5/7] drivers/atm/eni.c: ensure arguments to request_irq
 and free_irq are compatible
Date: Sun, 11 Mar 2012 22:08:51 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1203112208040.1958@localhost6.localdomain6>
References: <201203112058.q2BKwBCS024617@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	kernel-janitors@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4-relais-sop.national.inria.fr ([192.134.164.105]:13106
	"EHLO mail4-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751867Ab2CKVIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 17:08:54 -0400
In-Reply-To: <201203112058.q2BKwBCS024617@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Mar 2012, Chas Williams (CONTRACTOR) wrote:

> i am pretty sure that request_irq() shouldnt be changed but rather
> free_irq() changed.  the last argument of request_irq() is passed to the
> interrupt routine (ent_int in this case).  if you change that you need
> to update the interrupt routine.  fixing free_irq would be easier.

OK, thanks for the feedback.  I will fix it up.

julia

>
> In message <1331494587-12196-6-git-send-email-Julia.Lawall@lip6.fr>,Julia Lawall writes:
>> Convert call to request_irq so that the last argument is the same as the
>> second argument of the subsequent call to free_irq.  Without this
>> property, free_irq does nothing.
>>
>> I have chosen to keep the call to free_irq as is, because its second
>> argument is more like its first argument.
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
