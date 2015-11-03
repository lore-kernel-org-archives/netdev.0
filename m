From: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Subject: Re: [RFC][PATCH] net: arinc429: Add ARINC-429 stack
Date: Tue, 3 Nov 2015 23:15:53 +0300
Message-ID: <1619592151.20151103231553@cogentembedded.com>
References: <1446419775-5215-1-git-send-email-marex@denx.de>
  <CAAP7uc+z==A=VZqYXmsQB4CAuTXvbwefhVyUdud0ES30rbaBsg@mail.gmail.com>
  <CAAP7ucLEN3-_9agX_miLu4n6Vcnbd+jBouMXmEg0x196Q1OZmg@mail.gmail.com>
  <201511031833.27689.marex@denx.de>
Reply-To: Vostrikov Andrey <andrey.vostrikov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Aleksander Morgado <aleksander@aleksander.es>,
	"Marc Kleine-Budde" <mkl@pengutronix.de>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:36461 "EHLO
	mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899AbbKCUQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 15:16:07 -0500
Received: by lfs39 with SMTP id 39so971108lfs.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 12:16:06 -0800 (PST)
In-Reply-To: <201511031833.27689.marex@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Marek.

> So, considering that hi3593 which as 2x RX and 1x TX port, what about
> registering one device per port and be done with it ?
Yes, that is fine. It could be easily done.
Just drop tx requests on rx channel and vice versa.

-- 
Best regards,
Andrey Vostrikov
