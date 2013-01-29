From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH v3 1/1 net-next] net: fec: add napi support to improve proformance
Date: Tue, 29 Jan 2013 13:03:38 +0800
Message-ID: <CAHrpEqTQBbNVAVN5FDTYAnnO9gX_WXdC9xgq7X4+gtYJoHjpDg@mail.gmail.com>
References: <1359077343-8271-1-git-send-email-Frank.Li@freescale.com>
	<20130125043311.GA4141@ppwaskie-mobl2.amr.corp.intel.com>
	<20130125222306.GA2523@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Frank Li <Frank.Li@freescale.com>, shawn.guo@linaro.org,
	B38611@freescale.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:52171 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab3A2FDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 00:03:39 -0500
Received: by mail-wi0-f182.google.com with SMTP id hn14so27628wib.15
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2013 21:03:38 -0800 (PST)
In-Reply-To: <20130125222306.GA2523@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/26 Francois Romieu <romieu@fr.zoreil.com>:
> Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> :
> [...]
>> Also, when you're disabling interrupts above, you're doing that in your
>> HW interrupt handler, you should be using spin_lock_irqsave()/irq_restore().
>
> Does the platform forbid to defer FEC_EIR / FEC_IEVENT write to the napi

I can clean FEC_IEVENT, but rx irq still issue if new package
received. I tested, performance drop if just clean FEC_IEVENT

> poll handler and only disable the irq through FEC_EIMR / FEC_IMASK in
> fec_enet_interrupt so as to remove the spinlock ?

I can remove this spin lock in other way.  I will send new patch.

>
> (Frank, please keep an empty line between variables declarations and
> function body).

Okay.

>
> --
> Ueimor
