From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: sja1000 platform data fixes
Date: Mon, 17 May 2010 22:39:57 -0700 (PDT)
Message-ID: <20100517.223957.235680128.davem@davemloft.net>
References: <4BF151D2.5030906@grandegger.com>
	<4BF155CF.3030905@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, Netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4BF155CF.3030905@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 17 May 2010 16:42:23 +0200

> Wolfgang Grandegger wrote:
>> The member "clock" of struct "sja1000_platform_data" is documented as
>> "CAN bus oscillator frequency in Hz" but it's actually used as the CAN
>> clock frequency, which is half of it. To avoid further confusion, this
>> patch fixes it by renaming the member to "osc_freq". That way, also
>> non mainline users will notice the change. The platform code for the
>> relevant boards is updated accordingly. Furthermore, pre-defined
>> values are now used for the members "ocr" and "cdr".
>> 
>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>> CC: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied, thanks everyone.
