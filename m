From: Lucas Stach <l.stach@pengutronix.de>
Subject: Re: [PATCH resend 1/3] Revert "net: fec: fix missing napi_disable
 call"
Date: Mon, 29 Apr 2013 15:46:57 +0200
Message-ID: <1367243217.4100.13.camel@weser.hi.pengutronix.de>
References: <1366966330-5181-1-git-send-email-l.stach@pengutronix.de>
	 <CAHrpEqQLkjCOq0doaM0zNMkgjNkE_pOLxjoFJWNPuQ6CRHCbBw@mail.gmail.com>
	 <20130426134415.GS1366@pengutronix.de>
	 <20130426.143309.1011152996477262852.davem@davemloft.net>
	 <20130427090545.GY1366@pengutronix.de>
	 <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	Fabio Estevam <festevam@gmail.com>,
	Shawn Guo <shawn.guo@linaro.org>
To: Frank Li <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47355 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853Ab3D2NsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 09:48:11 -0400
In-Reply-To: <CAHrpEqSi+caO5gSo1BZRGqytxhCOs-OuyjiCaG+7fnsnFBj77g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, den 27.04.2013, 18:26 +0800 schrieb Frank Li:
> >
> > - remove locking in a way that memory is freed which is in use
> 
> The purpose of remove lock is that fix dead lock.

Could you please elaborate? What is the exact situation which caused a
deadlock here? I tried to see what's happening from your changelogs, but
I'm not sure I can follow here. Wasn't the problem more of the used
spinlocks not being IRQ-save and thus potentially creating a deadlock?

Regards,
Lucas
-- 
Pengutronix e.K.                           | Lucas Stach                 |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-5076 |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
