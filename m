From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable call"
Date: Thu, 2 May 2013 09:51:00 +0800
Message-ID: <CAHrpEqR6b0dy1AWsakS-z7TCe5oz5NYdpo+JWSh+K+OzPLrCVw@mail.gmail.com>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
	<CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
	<20130426134415.GS1366@pengutronix.de>
	<20130426.143309.1011152996477262852.davem@davemloft.net>
	<20130427090545.GY1366@pengutronix.de>
	<CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
	<1367243217.4100.13.camel@weser.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:41474 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759186Ab3EBBvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 21:51:02 -0400
Received: by mail-wi0-f170.google.com with SMTP id hq12so91544wib.5
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 18:51:00 -0700 (PDT)
In-Reply-To: <1367243217.4100.13.camel@weser.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/4/29 Lucas Stach <l.stach@pengutronix.de>:
> What is the exact situation which caused a
> deadlock here? I tried to see what's happening from your changelogs, but
> I'm not sure I can follow here. Wasn't the problem more of the used
> spinlocks not being IRQ-save and thus potentially creating a deadlock?

You can view below email thread.
http://www.spinics.net/lists/netdev/msg225240.html

The main problem network API use spin_lock_bh only now. So it does not
prefer use irq to handle skb process.
