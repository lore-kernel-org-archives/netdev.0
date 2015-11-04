From: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Wed, 4 Nov 2015 18:03:16 +0300
Message-ID: <338664525.20151104180316@cogentembedded.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
  <201511032243.03029.marex@denx.de>
  <CAAP7ucJbWFZ-DCH1dhvJUYcYosTfYgsHx9Mdnwq+K166yjYJaA@mail.gmail.com>
  <201511041454.16413.marex@denx.de>
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
Received: from mail-lb0-f173.google.com ([209.85.217.173]:33886 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030363AbbKDPDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 10:03:30 -0500
Received: by lbbwb3 with SMTP id wb3so18204116lbb.1
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2015 07:03:28 -0800 (PST)
In-Reply-To: <201511041454.16413.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Marek.

> About the parity -- can we add some flag into the datagram to indicate we
> want hardware to calculate the parity for that particular datagram for us?
> And we'd also need to indicate what type of parity. I dunno if this is worth
> the hassle.
This  is HW configuration property, it does not belong to  datagram. Also for TX
channels,  parity could  be  two  kinds:  odd and even, for RX it is only
on/off.

Parity  is  not  the  only property that needs to be configured in HW,
following could be needed as well,
- label bit flipping (on or off)
- rate change (low / high)
-  label  filters  and  label  priority matching (this could be HoltIC
specific)

I  suppose  all  these  properties  are  configured  only  once, at interface
initialization.

-- 
Best regards,
Andrey Vostrikov
