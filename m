From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH 05/13] ARM: dts: DRA7: Add DCAN nodes
Date: Tue, 9 Sep 2014 11:37:28 +0300
Message-ID: <540EBC48.70302@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com> <1410185442-907-6-git-send-email-rogerq@ti.com> <540DDBE0.5090004@cogentembedded.com> <540EBABA.9090009@ti.com> <540EBBAE.9030300@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<wg@grandegger.com>, <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <540EBBAE.9030300@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marc,

On 09/09/2014 11:34 AM, Marc Kleine-Budde wrote:
> On 09/09/2014 10:30 AM, Roger Quadros wrote:
>>>> +            compatible = "bosch,d_can";
>>>> +            ti,hwmods = "dcan1";
>>>> +            reg = <0x4ae3c000 0x2000>,
>>>> +                  <0x558 0x4>; /* index to RAMINIT reg within syscon */
>>>> +            raminit-syscon = <&dra7_ctrl_core>;
>>>> +            raminit-start-bit = <3>;
>>>> +            raminit-done-bit = <1>;
>>>> +            raminit-pulse;
>>>
>>>    Hm, aren't the above 4 properties vendor specific? If so, they should start with a vendor prefix and comma.
>>
>> At least for now I don't know about any other platform other than TI using a RAMINIT register outside the
>> CAN register space. However the mechanism is generic enough and not limited to TI platforms.
>>
>> I don't mind vendor prefix or not, but would like to hear the opinion of the CAN maintainers as to what they would prefer.
> 
> I don't know of any c_can/d_can implementation outside of TI that
> implements the raminit outside of the register space. So a "ti," prefix
> seems appropriate.
> 

Fine, I'll re-spin this with the "ti," prefix. Thanks.

cheers,
-roger
 

