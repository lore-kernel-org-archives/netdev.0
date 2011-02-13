From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v7 1/1] can: c_can: Added support for
 Bosch C_CAN controller
Date: Sun, 13 Feb 2011 11:05:30 -0800 (PST)
Message-ID: <20110213.110530.98884040.davem@davemloft.net>
References: <1297419478-27667-1-git-send-email-bhupesh.sharma@st.com>
	<4D56C0ED.1040201@pengutronix.de>
	<20110213.105216.27797609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhupesh.sharma@st.com, netdev@vger.kernel.org,
	Socketcan-core@lists.berlios.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46756
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754738Ab1BMTEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 14:04:55 -0500
In-Reply-To: <20110213.105216.27797609.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sun, 13 Feb 2011 10:52:16 -0800 (PST)

> From: Marc Kleine-Budde <mkl@pengutronix.de>
> Date: Sat, 12 Feb 2011 18:18:37 +0100
> 
>> On 02/11/2011 11:17 AM, Bhupesh Sharma wrote:
>>> Bosch C_CAN controller is a full-CAN implementation which is compliant
>>> to CAN protocol version 2.0 part A and B. Bosch C_CAN user manual can be
>>> obtained from:
>>> http://www.semiconductors.bosch.de/media/en/pdf/ipmodules_1/
>>> c_can/users_manual_c_can.pdf
>>> 
>>> This patch adds the support for this controller.
>>> The following are the design choices made while writing the controller
>>> driver:
>>> 1. Interface Register set IF1 has be used only in the current design.
>>> 2. Out of the 32 Message objects available, 16 are kept aside for RX
>>>    purposes and the rest for TX purposes.
>>> 3. NAPI implementation is such that both the TX and RX paths function
>>>    in polling mode.
>>> 
>>> Signed-off-by: Bhupesh Sharma <bhupesh.sharma@st.com>
>> 
>> Good work!
>> 
>> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> 
> Applied.

Actually, I'm reverting because this causes build regressions:

ERROR: "clk_get_rate" [drivers/net/can/c_can/c_can_platform.ko] undefined!
ERROR: "clk_get" [drivers/net/can/c_can/c_can_platform.ko] undefined!
ERROR: "clk_put" [drivers/net/can/c_can/c_can_platform.ko] undefined!
