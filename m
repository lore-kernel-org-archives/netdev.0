From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 16:07:30 +0100
Message-ID: <201511041607.30577.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <201511041454.16413.marex@denx.de> <338664525.20151104180316@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:48258 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365AbbKDPHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:07:40 -0500
In-Reply-To: <338664525.20151104180316@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 04, 2015 at 04:03:16 PM, Vostrikov Andrey wrote:
> Hi, Marek.

Hi,

> > About the parity -- can we add some flag into the datagram to indicate we
> > want hardware to calculate the parity for that particular datagram for
> > us? And we'd also need to indicate what type of parity. I dunno if this
> > is worth the hassle.
> 
> This  is HW configuration property, it does not belong to  datagram. Also
> for TX channels,  parity could  be  two  kinds:  odd and even, for RX it
> is only on/off.

There are datagrams which do contain parity and ones which do not contain it,
correct ? Thus, it's a property of that particular datagram.

> Parity  is  not  the  only property that needs to be configured in HW,
> following could be needed as well,
> - label bit flipping (on or off)

This is hardware property.

> - rate change (low / high)

This is again hardware configuration -- you have to configure the link speed
before you do RX/TX.

> -  label  filters  and  label  priority matching (this could be HoltIC
> specific)
> 
> I  suppose  all  these  properties  are  configured  only  once, at
> interface initialization.

These three above, yes. Parity, I don't think so.

Best regards,
Marek Vasut
