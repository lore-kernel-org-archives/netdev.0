From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Sun, 28 Apr 2013 19:57:59 +0200
Message-ID: <20130428175759.GA8112@electric-eye.fr.zoreil.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	Lucas Stach <l.stach@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49708 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970Ab3D1R6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Apr 2013 13:58:12 -0400
Content-Disposition: inline
In-Reply-To: <CAHrpEqQbaFK-j00X+SQ200Aur4BSnvUuM4nq5pYWVyd5XMWDrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frank Li <lznuaa@gmail.com> :
[...]
> tg3_tx is safe method but need more lock.

It's the same design.

> But I think it is not related with this issue. I can change later.

It won't oops, sure. It will simply stop under high load or proper
timing.

-- 
Ueimor
