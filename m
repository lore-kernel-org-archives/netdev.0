From: <tthayer@altera.com>
Subject: [PATCHv2] Add support for standard D_CAN module RAM Init Bit
Date: Fri, 18 Apr 2014 09:03:13 -0500
Message-ID: <1397829794-9714-1-git-send-email-tthayer@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <socketcan@hartkopp.net>, <anilkumar@ti.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <tthayer.linux@gmail.com>
To: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<mkl@pengutronix.de>, <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0121.outbound.protection.outlook.com ([65.55.169.121]:17767
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751314AbaDRN6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2014 09:58:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The standard D_CAN module includes the RAM Init bit in one of the 
D_CAN registers. This patch will properly initialize the RAM Init
bit which is self-clearing when the RAM Init is complete.
This patch fixes a boot message reporting an invalid resource as
well as the message saying control memory is not used for raminit.

[PATCHv2] net: c_can: Add support for D_CAN RAM Init bit in D_CAN
