From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 17:56:53 +0100
Message-ID: <CAAP7ucLEN3-_9agX_miLu4n6Vcnbd+jBouMXmEg0x196Q1OZmg@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<56389C38.4080508@pengutronix.de>
	<CAAP7ucLhzqh8+QxYJwx-8-DqSb6YqV0ZXXVGqY=OUUnzAu5EVQ@mail.gmail.com>
	<201511031619.43802.marex@denx.de>
	<CAAP7uc+z==A=VZqYXmsQB4CAuTXvbwefhVyUdud0ES30rbaBsg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:33890 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995AbbKCQ4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 11:56:54 -0500
Received: by obbza9 with SMTP id za9so17175433obb.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 08:56:53 -0800 (PST)
In-Reply-To: <CAAP7uc+z==A=VZqYXmsQB4CAuTXvbwefhVyUdud0ES30rbaBsg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 5:18 PM, Aleksander Morgado
<aleksander@aleksander.es> wrote:
> On Tue, Nov 3, 2015 at 4:19 PM, Marek Vasut <marex@denx.de> wrote:
>>> , or the duplex TX/RX setup for channels
>>> (channels are either RX or TX, not both), or the local
>>> echoing/loopback (which wouldn't make much sense for TX-only
>>> channels).
>>
>> Aren't the RX-only/TX-only channels rather a special case ?
>
> They're actually the only case AFAIK. You've got systems generating
> streams of ARINC429 words (e.g. the IRS, the FMC...) and systems that
> may consume the streams from multiple independent channels (e.g. the
> IFE). I try to think of each logical bus as a single transmitter
> broadcasting to multiple receivers.

I've re-checked the spec and it does say that there may be systems
that act as source (TX) and sink (RX), e.g. DME, VOR or ILS. But in
those cases, they will actually have separate TX and RX physical
ports.

-- 
Aleksander
https://aleksander.es
