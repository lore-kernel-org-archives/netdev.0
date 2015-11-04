From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 16:19:45 +0100
Message-ID: <CAAP7ucJrkhJ=nqwruf0p+YOCdqtH5+N6pgeAY_qF9g7Wc6_XiA@mail.gmail.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
	<201511041454.16413.marex@denx.de>
	<338664525.20151104180316@cogentembedded.com>
	<201511041607.30577.marex@denx.de>
	<1938246043.20151104181806@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marek Vasut <marex@denx.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33725 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbbKDPTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:19:46 -0500
Received: by obbww6 with SMTP id ww6so15403400obb.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 07:19:46 -0800 (PST)
In-Reply-To: <1938246043.20151104181806@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 4, 2015 at 4:18 PM, Vostrikov Andrey
<andrey.vostrikov@cogentembedded.com> wrote:
>>> > About the parity -- can we add some flag into the datagram to indicate we
>>> > want hardware to calculate the parity for that particular datagram for
>>> > us? And we'd also need to indicate what type of parity. I dunno if this
>>> > is worth the hassle.
>>>
>>> This  is HW configuration property, it does not belong to  datagram. Also
>>> for TX channels,  parity could  be  two  kinds:  odd and even, for RX it
>>> is only on/off.
>
>> There are datagrams which do contain parity and ones which do not contain it,
>> correct ? Thus, it's a property of that particular datagram.

All ARINC words have bit #31 as parity bit; whether it's used or not
depends on the setup as Andrey says below.

> For   RX  side  it  is  both: datagram and HW (is it checked by receiver or not)
> But  for TX side it is HW property of transmitter, either OFF or ON (odd or even).




-- 
Aleksander
https://aleksander.es
