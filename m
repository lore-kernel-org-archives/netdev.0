From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 12:04:03 +0200
Message-ID: <4C1B4493.70102@grandegger.com>
References: <20100617105201.GA2015@bluebox.local> <4C1A2CDF.2040008@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Hans J. Koch" <hjk@linutronix.de>, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:42076 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752735Ab0FRKEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 06:04:06 -0400
In-Reply-To: <4C1A2CDF.2040008@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/17/2010 04:10 PM, Marc Kleine-Budde wrote:
> Hey Hans,
> 
> Hans J. Koch wrote:

>> +	priv->can.do_set_bittiming = flexcan_set_bittiming;

Yes, but we need to fix it globally anyway.

> using this callback is error prone, with respect to 3-sample and
> friends, see discussion on socketcan-core.
> 
>> +	priv->can.bittiming_const = &flexcan_bittiming_const;
>> +	priv->can.do_set_mode = flexcan_set_mode;
>> +	priv->can.restart_ms = 500;
> 
> should this be set in the driver?

No, the default is manual restart for all drivers.

Wolfgang.
