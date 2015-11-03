From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 18:33:27 +0100
Message-ID: <201511031833.27689.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <CAAP7uc+z==A=VZqYXmsQB4CAuTXvbwefhVyUdud0ES30rbaBsg@mail.gmail.com> <CAAP7ucLEN3-_9agX_miLu4n6Vcnbd+jBouMXmEg0x196Q1OZmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:34408 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330AbbKCRhq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 12:37:46 -0500
In-Reply-To: <CAAP7ucLEN3-_9agX_miLu4n6Vcnbd+jBouMXmEg0x196Q1OZmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, November 03, 2015 at 05:56:53 PM, Aleksander Morgado wrote:
> On Tue, Nov 3, 2015 at 5:18 PM, Aleksander Morgado
> 
> <aleksander@aleksander.es> wrote:
> > On Tue, Nov 3, 2015 at 4:19 PM, Marek Vasut <marex@denx.de> wrote:
> >>> , or the duplex TX/RX setup for channels
> >>> (channels are either RX or TX, not both), or the local
> >>> echoing/loopback (which wouldn't make much sense for TX-only
> >>> channels).
> >> 
> >> Aren't the RX-only/TX-only channels rather a special case ?
> > 
> > They're actually the only case AFAIK. You've got systems generating
> > streams of ARINC429 words (e.g. the IRS, the FMC...) and systems that
> > may consume the streams from multiple independent channels (e.g. the
> > IFE). I try to think of each logical bus as a single transmitter
> > broadcasting to multiple receivers.
> 
> I've re-checked the spec and it does say that there may be systems
> that act as source (TX) and sink (RX), e.g. DME, VOR or ILS. But in
> those cases, they will actually have separate TX and RX physical
> ports.

So, considering that hi3593 which as 2x RX and 1x TX port, what about
registering one device per port and be done with it ?

Best regards,
Marek Vasut
