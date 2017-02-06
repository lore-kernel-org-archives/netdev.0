From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] Documentation: devicetree: Add PHY no lane swap binding
Date: Mon, 6 Feb 2017 09:58:30 -0800
Message-ID: <c99f99ca-281b-065e-49e3-7fbbc5533517@gmail.com>
References: <1486223267-11875-1-git-send-email-lukma@denx.de>
 <20170204172329.GA8364@lunn.ch>
 <509fadc4-164c-7333-1871-fd6e615e57c9@gmail.com>
 <20170206151524.2ff0f799@jawa>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        jbrunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Jon Mason <jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Fabio Estevam <fabio.estevam-3arQi8VN3Tc@public.gmane.org>
To: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170206151524.2ff0f799@jawa>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 02/06/2017 06:15 AM, Lukasz Majewski wrote:
> Hi Florian, Andrew,
> 
>> Le 02/04/17 à 09:23, Andrew Lunn a écrit :
>>> On Sat, Feb 04, 2017 at 04:47:47PM +0100, Lukasz Majewski wrote:
>>>> Add the documentation to avoid PHY lane swapping. This is a boolean
>>>> entry to notify the phy device drivers that the TX/RX lanes NO need
>>>
>>> that the TX/RX lanes should not be swapped.
>>>
>>>> to be swapped.
>>>> The use case for this binding mostly happens after wrong HW
>>>> configuration of PHY IC during bootstrap.
>>>>
>>>> Signed-off-by: Lukasz Majewski <lukma-ynQEQJNshbs@public.gmane.org>
>>>> ---
>>>>  Documentation/devicetree/bindings/net/phy.txt | 4 ++++
>>>>  1 file changed, 4 insertions(+)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/phy.txt
>>>> b/Documentation/devicetree/bindings/net/phy.txt index
>>>> fb5056b..5e25bc9 100644 ---
>>>> a/Documentation/devicetree/bindings/net/phy.txt +++
>>>> b/Documentation/devicetree/bindings/net/phy.txt @@ -39,6 +39,10 @@
>>>> Optional Properties:
>>>>  - enet-phy-lane-swap: If set, indicates the PHY will swap the
>>>> TX/RX lanes to compensate for the board being designed with the
>>>> lanes swapped. 
>>>> +- enet-phy-lane-no-swap: If set, indicates that PHY will disable
>>>> swap of the
>>>> +  TX/RX lanes. This binding allows the PHY to work correcly after
>>>> e.g. wrong
>>>> +  bootstrap configuration caused by issues in PCB layout design.
>>
>> s/binding/property/
>>
>>>> +
>>>
>>> We are leaving it undefined what it means if neither
>>> enet-phy-lane-no-swap nor enet-phy-lane-swap properties are present.
>>> Do we want to define this? That the swap should be left untouched by
>>> the driver?
>>
>> Since this is a description of the hardware, absence of a properties
>> should mean that the driver is at freedom to either keep the hardware
>> defaults, or come up with its own settings that are sensible for that
>> particular PHY device.
>>
>> What would you see clarified here?
> 
> Any more comments to this patch?
> 
> Is the explanation informative enough?

Please resubmit as part of your PHY driver changes, and change binding
in the description above for property.
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
