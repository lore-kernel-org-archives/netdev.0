From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Mon, 29 Apr 2013 07:45:19 +0800
Message-ID: <CAHrpEqRn0tpgN-ax5FE2+X_+zb91oDwnxz4PJLZcJ6UR2oZgMw@mail.gmail.com>
References: <20130426134415.GS1366@pengutronix.de>
	<20130426.143309.1011152996477262852.davem@davemloft.net>
	<20130427090545.GY1366@pengutronix.de>
	<CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
	<20130427120619.GA26097@electric-eye.fr.zoreil.com>
	<CAHrpEqTE-oGcdMVk2LMffW0JWNgJ-b_+RakpCOVBy6WxA_ARGg@mail.gmail.com>
	<20130427191600.GA30373@electric-eye.fr.zoreil.com>
	<CAHrpEqRnWXV7jC+QuQe+chiEJCXOkmOz1tEdna2SPfPBQ2E=1Q@mail.gmail.com>
	<20130428093917.GA4540@electric-eye.fr.zoreil.com>
	<CAHrpEqQbaFK-j00X+SQ200Aur4BSnvUuM4nq5pYWVyd5XMWDrg@mail.gmail.com>
	<20130428175759.GA8112@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:60800 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756498Ab3D1XpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 19:45:21 -0400
Received: by mail-we0-f182.google.com with SMTP id s43so5007507wey.27
        for <netdev@vger.kernel.org>; Sun, 28 Apr 2013 16:45:20 -0700 (PDT)
In-Reply-To: <20130428175759.GA8112@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/29, Francois Romieu <romieu@fr.zoreil.com>:
> Frank Li <lznuaa@gmail.com> :
> [...]
>> tg3_tx is safe method but need more lock.
>
> It's the same design.
>
>> But I think it is not related with this issue. I can change later.
>
> It won't oops, sure. It will simply stop under high load or proper
> timing.

It is difference problem.
It should be new patch.

Do you have test step to reproduce the problem what you said?

>
> --
> Ueimor
>
