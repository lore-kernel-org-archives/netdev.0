From: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 18:18:06 +0300
Message-ID: <1938246043.20151104181806@cogentembedded.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
  <201511041454.16413.marex@denx.de>
  <338664525.20151104180316@cogentembedded.com> <201511041607.30577.marex@denx.de>
Reply-To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33485 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932373AbbKDPSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:18:09 -0500
Received: by lfbf136 with SMTP id f136so40442157lfb.0
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 07:18:08 -0800 (PST)
In-Reply-To: <201511041607.30577.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Marek.

>> > About the parity -- can we add some flag into the datagram to indicate we
>> > want hardware to calculate the parity for that particular datagram for
>> > us? And we'd also need to indicate what type of parity. I dunno if this
>> > is worth the hassle.
>> 
>> This  is HW configuration property, it does not belong to  datagram. Also
>> for TX channels,  parity could  be  two  kinds:  odd and even, for RX it
>> is only on/off.

> There are datagrams which do contain parity and ones which do not contain it,
> correct ? Thus, it's a property of that particular datagram.
For   RX  side  it  is  both: datagram and HW (is it checked by receiver or not)
But  for TX side it is HW property of transmitter, either OFF or ON (odd or even).

-- 
Best regards,
Andrey Vostrikov
