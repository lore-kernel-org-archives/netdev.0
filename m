From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] can: ti_hecc: Replace platform dependency with ARM
 dependency
Date: Sun, 22 Dec 2013 01:16:44 +0300
Message-ID: <52B6134C.5080301@cogentembedded.com>
References: <1387570460-18409-1-git-send-email-ezequiel.garcia@free-electrons.com> <52B4B3E7.8050601@cogentembedded.com> <20131220213341.GA452@localhost> <52B602C7.4080307@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:39652 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756047Ab3LUVQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 16:16:41 -0500
Received: by mail-la0-f46.google.com with SMTP id eh20so1659733lab.5
        for <netdev@vger.kernel.org>; Sat, 21 Dec 2013 13:16:39 -0800 (PST)
In-Reply-To: <52B602C7.4080307@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/22/2013 12:06 AM, Marc Kleine-Budde wrote:

>>>> OMAP's ti_hecc driver is used to support the CAN controller on many omap2plus
>>>> SoCs (OMAP2430, OMAP3, OMAP4, OMAP5 and AM335x), so it's wrong to make this
>>>> depend on OMAP3 only. Take an extra step, to get wider build coverage, and make
>>>> the driver depend on ARM.

>>>      To have a real wide coverage, it's probably worth adding '|| COMIPLE_TEXT'
>>> to 'depends on ARCH_OMAP2PLUS'?

>> Yup, and that was my exact proposal on my reply to v1 (which I forgot to detail
>> in v2). I'd say it's Marc's call.

> Convinced, I've added the v1 of this patch to can-next together with a
> || COMIPLE_TEXT.

    Sorry, I meant COMPILE_TEST, of course. :-<

> regards,
> Marc

WBR, Sergei
