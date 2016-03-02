From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next V2 04/16] net: fec: reduce interrupts
Date: Wed, 2 Mar 2016 10:44:53 -0600
Message-ID: <CAHrpEqR0-POp__KfHUdKVf3kE5H5zHMTYD4j7ADGNZRf9dgfCg@mail.gmail.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
	<1456360619-24390-5-git-send-email-troy.kisky@boundarydevices.com>
	<VI1PR0401MB18558A7D0A57FA8EDBAD5EABFFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
	<56D710EB.5000201@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fugang Duan <fugang.duan@nxp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"b38611@freescale.com" <b38611@freescale.com>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>,
	"l.stach@pengutronix.de" <l.stach@pengutronix.de>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"tremyfr@gmail.com" <tremyfr@gmail.com>,
	"linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"laci@boundarydevices.com" <laci@boundarydevices.com>,
	"shawnguo@kernel.org" <shawnguo@kernel.org>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"stillcompiling@gmail.com" <stillcompiling@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"arnd@arndb.de" <arnd@arndb.de>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35823 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbcCBQoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 11:44:54 -0500
Received: by mail-oi0-f68.google.com with SMTP id r187so4336769oih.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 08:44:53 -0800 (PST)
In-Reply-To: <56D710EB.5000201@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2016 at 10:12 AM, Troy Kisky
<troy.kisky@boundarydevices.com> wrote:
> it is going to be delayed for a very long time.
> Should it be moved to the napi routine?

No!

irq can generate.  Compared irq enable is not controlled by EIMR, but TCSR.

Original code is correct.

best regards
Frank Li
