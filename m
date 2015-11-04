From: Marek Vasut <marex@denx.de>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 16:33:33 +0100
Message-ID: <201511041633.33504.marex@denx.de>
References: <1446419775-5215-1-git-send-email-marex@denx.de> <1938246043.20151104181806@cogentembedded.com> <CAAP7ucJrkhJ=nqwruf0p+YOCdqtH5+N6pgeAY_qF9g7Wc6_XiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Aleksander Morgado <aleksander@aleksander.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43987 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030324AbbKDPdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:33:51 -0500
In-Reply-To: <CAAP7ucJrkhJ=nqwruf0p+YOCdqtH5+N6pgeAY_qF9g7Wc6_XiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 04, 2015 at 04:19:45 PM, Aleksander Morgado wrote:
> On Wed, Nov 4, 2015 at 4:18 PM, Vostrikov Andrey
> 
> <andrey.vostrikov@cogentembedded.com> wrote:
> >>> > About the parity -- can we add some flag into the datagram to
> >>> > indicate we want hardware to calculate the parity for that
> >>> > particular datagram for us? And we'd also need to indicate what type
> >>> > of parity. I dunno if this is worth the hassle.
> >>> 
> >>> This  is HW configuration property, it does not belong to  datagram.
> >>> Also for TX channels,  parity could  be  two  kinds:  odd and even,
> >>> for RX it is only on/off.
> >> 
> >> There are datagrams which do contain parity and ones which do not
> >> contain it, correct ? Thus, it's a property of that particular
> >> datagram.
> 
> All ARINC words have bit #31 as parity bit; whether it's used or not
> depends on the setup as Andrey says below.

Can bit 31 be ever used for DATA instead of parity ? Or is this just me
not understanding the parlance of the specification, where "DATA" actually
means "DATA with parity" ?

Best regards,
Marek Vasut
