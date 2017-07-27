From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [PATCH 1/4] can: dev: Add support for limiting configured bitrate
Date: Wed, 26 Jul 2017 20:44:33 -0500
Message-ID: <05ca373b-977c-1a59-69fe-c17e5ec4ae75@ti.com>
References: <20170719233654.25908-1-fcooper@ti.com>
 <20170719233654.25908-2-fcooper@ti.com>
 <f45ea1b4-0f46-0002-a89b-b997f2693bb5@hartkopp.net>
 <055c00f5-0775-4e35-309c-0d1c8aa0afdf@ti.com>
 <20170726200403.GD6873@airbook.vandijck-laurijssen.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726200403.GD6873@airbook.vandijck-laurijssen.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Kurt,
On 07/26/2017 03:04 PM, Kurt Van Dijck wrote:
> Hi,
> 
> I know my response is late ...
> 
>> Hi Oliver
>> On 07/20/2017 02:43 AM, Oliver Hartkopp wrote:
>>> Hi Franklin,
>>>
>>> On 07/20/2017 01:36 AM, Franklin S Cooper Jr wrote:
>>>
>>>> +#ifdef CONFIG_OF
>>>> +void of_transceiver_is_fixed(struct net_device *dev)
>>>> +{
>>>
>>> (..)
>>>
>>>> +}
>>>> +EXPORT_SYMBOL(of_transceiver_is_fixed);
>>>> +#endif
>>>
>>> I'm not sure about the naming here.
>>>
>>> As this is a CAN transceiver related option it should be named accordingly:
> 
> I contest the the name too:
> 1) the can transceiver isn't fixed at all, it limited to the higher
> bitrates.

Its "possible" that this subnode may have additional properties beyond
bitrates in the future. But your right as of now it is specifically
addressing max bit rates. The naming of this function and subnode is
based on "fixed-link". So "fixed" is just implying that certain
properties can't be changed.

> 
> 2) of_can_transceiver_is_fixed suggests to test if a transceiver is
> fixed, it does not suggest to load some properties from the device tree.
> of_can_load_transceiver looks way more clear to me.

I address this partially in my rev 2 that I've already sent. I'm now
using of_can_transceiver_fixed. The fact its of_ already implies it is
loading properties from device tree. So I don't think
of_can_load_transceiver really makes things clearer.

> 
> That's my opinion.
> The important things, like the contents of the functions, look good.

You mind throwing your two cents in the thread for my latest patch?
Specifically the conversation regarding naming the properties. A couple
of people prefer to not use "arbitration" in one of the property names.
Currently I believe there are two options on property names that can be
used and I'm open to a majority vote on which one to go with.

> 
> Kind regards,
> Kurt Van Dijck
> 
