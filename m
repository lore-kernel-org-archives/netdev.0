From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] sh_eth: remove unchecked interrupts
Date: Thu, 1 Dec 2016 20:36:00 +0300
Message-ID: <228704e3-fe33-1c1f-61a1-7db451af5faf@cogentembedded.com>
References: <20161201140642.28583-1-chris.brandt@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms+renesas@verge.net.au>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Chris Brandt <chris.brandt@renesas.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33166 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754409AbcLARgE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:36:04 -0500
Received: by mail-lf0-f45.google.com with SMTP id c13so176839049lfg.0
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 09:36:03 -0800 (PST)
In-Reply-To: <20161201140642.28583-1-chris.brandt@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2016 05:06 PM, Chris Brandt wrote:

> When streaming a lot of data and the RZ can't keep up, some status bits
> will get set that are not being checked or cleared which cause the
> following messages and the Ethernet driver to stop working. This
> patch fixes that issue.
>
> irq 21: nobody cared (try booting with the "irqpoll" option)
> handlers:
> [<c036b71c>] sh_eth_interrupt
> Disabling IRQ #21
>
> Fixes: db893473d313a4ad ("sh_eth: Add support for r7s72100")
> Signed-off-by: Chris Brandt <chris.brandt@renesas.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
