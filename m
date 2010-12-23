From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Thu, 23 Dec 2010 21:33:05 +0100
Message-ID: <4D13B201.1090906@hartkopp.net>
References: <20101223093627.GA325@e-circ.dyndns.org>	<20101223094302.GB325@e-circ.dyndns.org> <4D135BC3.6070707@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:47336 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab0LWUdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Dec 2010 15:33:07 -0500
In-Reply-To: <4D135BC3.6070707@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Kurt,

thanks for the effort to make this driver available in Mainline!

>> +
>> +MODULE_DESCRIPTION("socketcan softing driver");

MODULE_DESCRIPTION("Softing CAN driver");

MODULE_DESCRIPTION("Softing DPRAM CAN driver");

???

>> diff --git a/drivers/net/can/softing/softing_platform.h b/drivers/net/can/softing/softing_platform.h
>> new file mode 100644
>> index 0000000..9ff69a1
>> --- /dev/null
>> +++ b/drivers/net/can/softing/softing_platform.h

Shouldn't this file be placed in include/linux/can/platform/softing.h ??

Regards,
Oliver
