From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [PATCH V2 5/5] net: can: ifi: Add IFI CANFD IP support
Date: Sat, 23 Jan 2016 00:11:48 +0000
Message-ID: <020FA2C7-F92E-49F9-BF52-CFFCAAB7C82F@intel.com>
References: <1452538083-7331-5-git-send-email-marex@denx.de>
 <201601201358.04790.marex@denx.de> <569F944A.4090201@pengutronix.de>
 <201601201525.42143.marex@denx.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_38513DC2-5DC1-4D64-9A3A-D1A61E926FD0";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	"Mark Rutland" <mark.rutland@arm.com>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Marek Vasut <marex@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7192 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927AbcAWALu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jan 2016 19:11:50 -0500
In-Reply-To: <201601201525.42143.marex@denx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Apple-Mail=_38513DC2-5DC1-4D64-9A3A-D1A61E926FD0
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii;
	delsp=yes;
	format=flowed

Marek Vasut <marex@denx.de> wrote:

> I see, so adding u32 also here works. I'm starting to wonder if the BIT
> macro is really that nice and if I shouldn't just use (1 << n) as usual.

Actually, (1 << n) is not so good either when n is 31 - it can trigger  
overflow warnings since it will be presumed to be a signed value. (1U << n)  
should avoid that problem. Unfortunately, BIT() uses 1UL which produces  
64-bit values on 64-bit arches. The bit ops are kind of a mess in that way.  
It would be nicer if BIT was restricted to int-size values and a new BIT_UL  
or something would produce the long values.
--Apple-Mail=_38513DC2-5DC1-4D64-9A3A-D1A61E926FD0--
