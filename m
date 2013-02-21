From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix crash at mx53 qsb board
Date: Wed, 20 Feb 2013 23:19:37 -0300
Message-ID: <CAOMZO5CiBFBUEFGArceE=7Q25B7ZAj4GKZgGF0n+4KM1oCJjBA@mail.gmail.com>
References: <1361408848-14118-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: lznuaa@gmail.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	shawn.guo@linaro.org, B38611@freescale.com, s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:37235 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab3BUCTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 21:19:40 -0500
Received: by mail-vb0-f52.google.com with SMTP id fa15so5323974vbb.25
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2013 18:19:38 -0800 (PST)
In-Reply-To: <1361408848-14118-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 20, 2013 at 10:07 PM, Frank Li <Frank.Li@freescale.com> wrote:
> Unable to handle kernel NULL pointer dereference at virtual address 00000002
> pgd = 80004000
> [00000002] *pgd=00000000
> Internal error: Oops: 5 [#1] SMP ARM
> Modules linked in:
> CPU: 0    Not tainted  (3.8.0-rc7-next-20130215+ #346)
> PC is at fec_enet_interrupt+0xd0/0x348
> LR is at fec_enet_interrupt+0xb8/0x348
> pc : [<80372b7c>]    lr : [<80372b64>]    psr: 60000193
> sp : df855c20  ip : df855c20  fp : df855c74
> r10: 00000516  r9 : 1c000000  r8 : 00000000
> r7 : 00000000  r6 : 00000000  r5 : 00000000  r4 : df9b7800
> r3 : df9b7df4  r2 : 00000000  r1 : 00000000  r0 : df9b7d34
>
> It is possible that issue a irq between request_irq and fec_enet_init.
> Irq handle will be called but driver data structure is not ready yet.
>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

Tested-by: Fabio Estevam <fabio.estevam@freescale.com>
