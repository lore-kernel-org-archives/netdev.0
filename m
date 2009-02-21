From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: Re: NAPI of many interfaces with just an interruption source
Date: Sat, 21 Feb 2009 19:15:16 +0100
Message-ID: <b0438a630902211015q2209e441g6deb6083f84df0ff@mail.gmail.com>
References: <20090220105413.55e4f5f6@extreme>
	 <20090221131251.GA28821@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:25020 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbZBUSPS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 13:15:18 -0500
Received: by fg-out-1718.google.com with SMTP id 16so2247268fgg.17
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2009 10:15:16 -0800 (PST)
In-Reply-To: <20090221131251.GA28821@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your answers...

I understand that yes... if there is just an irq, the NAPI structure
should be one also...

The question is... I have one napi (inserted in an struct hss_t). This
hss structure has pointers to four struct port (each one is a network
device). So... When I detect the first IRQ, I can detect the dev
origin of the irq, and call netif_rx_schedule for it
(netif_rx_schedule(dev, &port->hss->napi).

In the poll function, I can obtain hss from napi, but not the dev
(unless I store the value of the last calling dev in hss_t). Is this
the way?

Thanks

Miguel =C1ngel =C1lvarez
