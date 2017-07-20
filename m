From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [PATCH 1/4] can: dev: Add support for limiting configured bitrate
Date: Thu, 20 Jul 2017 10:55:51 -0500
Message-ID: <055c00f5-0775-4e35-309c-0d1c8aa0afdf@ti.com>
References: <20170719233654.25908-1-fcooper@ti.com>
 <20170719233654.25908-2-fcooper@ti.com>
 <f45ea1b4-0f46-0002-a89b-b997f2693bb5@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>,
        <dev.kurt@vandijck-laurijssen.be>, <andrew@lunn.ch>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <f45ea1b4-0f46-0002-a89b-b997f2693bb5@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Oliver
On 07/20/2017 02:43 AM, Oliver Hartkopp wrote:
> Hi Franklin,
> 
> On 07/20/2017 01:36 AM, Franklin S Cooper Jr wrote:
> 
>> +#ifdef CONFIG_OF
>> +void of_transceiver_is_fixed(struct net_device *dev)
>> +{
> 
> (..)
> 
>> +}
>> +EXPORT_SYMBOL(of_transceiver_is_fixed);
>> +#endif
> 
> I'm not sure about the naming here.
> 
> As this is a CAN transceiver related option it should be named accordingly:
> 
> E.g.
> 
>     can_transceiver_is_fixed
>     of_can_transceiver_is_fixed
>     ...
> 
> Especially as it is defined in include/linux/can/dev.h

Thanks for the feedback. I'll go with of_can_transceiver_is_fixed

> 
> Regards,
> Oliver
> 
> 
