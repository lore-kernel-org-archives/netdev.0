From: Dong Aisheng-B29396 <B29396@freescale.com>
Subject: RE: [PATCH] flexcan: disable bus error interrupts for the i.MX28
Date: Mon, 8 Oct 2012 09:42:58 +0000
Message-ID: <7FE21149F4667147B645348EC60578850B2AA918@039-SN2MPN1-011.039d.mgd.msft.net>
References: <5065A35B.3020702@grandegger.com>
 <20121007030858.GJ20231@S2101-09.ap.freescale.net>
 <50719647.4070404@grandegger.com>
 <7FE21149F4667147B645348EC60578850B2A361F@039-SN2MPN1-011.039d.mgd.msft.net>
 <507296F2.9010402@grandegger.com>
 <7FE21149F4667147B645348EC60578850B2A8D51@039-SN2MPN1-011.039d.mgd.msft.net>
 <50729D73.3050409@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux-CAN <linux-can@vger.kernel.org>,
	Hui Wang <jason77.wang@gmail.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <50729D73.3050409@pengutronix.de>
Content-Language: en-US
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>Sent: Monday, October 08, 2012 5:32 PM
>To: Dong Aisheng-B29396
>Cc: Wolfgang Grandegger; Shawn Guo; Linux Netdev List; Linux-CAN; Hui Wang
>Subject: Re: [PATCH] flexcan: disable bus error interrupts for the i.MX28
>Importance: High
>
>On 10/08/2012 11:13 AM, Dong Aisheng-B29396 wrote:
>>>> I just checked our ic guy of flexcan, it seems he also had no sense
>>>> of
>>> this issue.
>>>>
>>>> Below is some version info what I got:
>>>> Mx6s use FlexCAN3, with IP version 10.00.12.00
>>>> Mx53 use FlexCAN2 (with glitch filter), with IP version 03.00.00.00
>>>> Mx28 use FlexCAN2 (with glitch filter), with IP version 03.00.04.00
>>>> Mx35 use FlexCAN2 (without glitch filter) , with IP version
>>>> 03.00.00.00
>>>> Mx25 use FlexCAN2 (without glitch filter), with IP version
>>>> 03.00.00.00 I'm not sure if mx6q has such issue.
>>>
>>> OK, we need to find that out experimentally.
>>>
>> Our IC owner double checked the MX35 and MX53 IP and found the RX_WARN
>> & TX_WARN Interrupt source actually are not connected to ARM.
>
>Does this mean it's a SoC problem, not a problem of the ip core?
>
It's not a problem of ip core, it's about how to use the IP.
I do not know why some i.MX SoCs does not use rx/tx warn interrupts.

>> That means flexcan will not trigger interrupt to ARM core even RX_WARN
>> or TX_WARN Happens.
>> This may be the root cause that why you cannot see RX_WARN interrupt
>> if not enable bus error interrupt on mx35.
>> He also checked that mx6q has the rx/tx warning interrupt connected to
>arm.
>> So we guess mx6q does not have this issue.
>> Anyway, we can test to confirm.
>
>What about mx25?
>
For mx25 and mx28, he could not access it now.
Will check tomorrow.

Regards
Dong Aisheng

