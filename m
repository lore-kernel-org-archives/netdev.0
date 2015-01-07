From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next v1 2/3] ARM: imx: add FEC sleep mode callback function
Date: Wed, 7 Jan 2015 01:44:16 -0200
Message-ID: <CAOMZO5AnB-hLHpqbznpqrSromDYv+GbW8tut=EC4A9az3Qf+3g@mail.gmail.com>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
	<1419413441-3406-3-git-send-email-b38611@freescale.com>
	<20150106114807.GL24511@dragon>
	<BLUPR03MB373F1A5D01A8A6D16DC3364F5460@BLUPR03MB373.namprd03.prod.outlook.com>
	<20150107023307.GA4928@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:38650 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbbAGDoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:44:17 -0500
Received: by mail-la0-f41.google.com with SMTP id hv19so1272988lab.0
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 19:44:16 -0800 (PST)
In-Reply-To: <20150107023307.GA4928@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 12:33 AM, Shawn Guo <shawn.guo@linaro.org> wrote:

> The GPR difference between SoCs can be encoded in device tree as well.
> It's pointless to repeat the same code pattern for every single
> platform, that need to set up GPR bits for enabling magic packet wake
> up, while the only difference is the register and bit offset.
>
> The platform code will become quite messy and unmaintainable if every
> device driver dump their GPR register setup code into platform.
>
> Sorry, but it's NACK from me.

This patch has already reached linux-next via Dave's tree as commit
456062b3ec6f5.

Should a revert patch be sent?

Also, this commit causes a build warning in linux-next:
arch/arm/mach-imx/mach-imx6sx.c:59:20: warning: 'imx6sx_enet_plt_init'
defined but not used [-Wunused-function]
