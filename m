From: Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>
Subject: Re: [PATCH 1/2] NET: PHY: Add PHY LED control binding.
Date: Thu, 9 Jun 2016 22:13:28 +0200
Message-ID: <cf8ba323-5d15-b5b6-fe7c-9f9a7da2c18a@hauke-m.de>
References: <1465163150-21429-1-git-send-email-hauke@hauke-m.de>
 <1465163150-21429-2-git-send-email-hauke@hauke-m.de>
 <20160608193008.GA20738@rob-hp-laptop> <3869397.kzojzy3Xzu@ws-stein>
 <f1e22176-d30a-be66-a4ea-dd0666775597@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	openwrt-zg6vgJgm1sizQB+pC5nmwQ@public.gmane.org, hauke.mehrtens-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	daniel.schwierzeck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, eckert.florian-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thomas.langer-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>,
	Alexander Stein <alexander.stein-93q1YBGzJSMe9JSWTWOYM3xStJ4P+DSV@public.gmane.org>,
	Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f1e22176-d30a-be66-a4ea-dd0666775597-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/09/2016 08:12 AM, John Crispin wrote:
> 
> 
> On 09/06/2016 08:06, Alexander Stein wrote:
>> On Wednesday 08 June 2016 14:30:08, Rob Herring wrote:
>>>> diff --git a/Documentation/devicetree/bindings/phy/phy-leds.txt
>>>> b/Documentation/devicetree/bindings/phy/phy-leds.txt new file mode 100644
>>>> index 0000000..1a35e3d
>>>> --- /dev/null
>>>> +++ b/Documentation/devicetree/bindings/phy/phy-leds.txt
>>>> @@ -0,0 +1,52 @@
>>>> +LED configuration for Ethernet phys
>>>> +
>>>> +All these properties are optional, not all properties are supported by
>>>> +all PHYs. When more then one property name is define for one LED the
>>>> +order they get applied is device depended.
>>>> +Property names:
>>>> +	led-const-on: conditions the LED should be constant on
>>>> +	led-pulse: condition the LED should be pulsed on
>>>> +	led-blink-slow: condition the LED should slowly blink
>>>
>>> How slow is slow?
>>
>> This depends on the MMD.INTERNAL.LEDCH.SBF setting which is 2 Hz by default.
>>
>>>> +	led-blink-fast: condition the LED should fast blink
>>>
>>> How fast is fast?
>>
>> This depends on the MMD.INTERNAL.LEDCH.FBF setting which is 16 Hz by default.
>>
>> Both can be set independently to 2, 4, 8 or 16 Hz.
>>
> 
> and both are intel/lantiq implementation specific and hence should not
> be part of a generic led-phy binding.

Ok, I can remove them, I think the constant on and the pulse are used by
many Ethernet PHYs.

> imho these leds should be exposed via a led driver and the configurtion
> should be exposed via a led driver specific trigger, in the same manner
> in which wireless macs do it.

Where is a good example on how this is done?
Is this then also triggered by the hardware or does the software has to
trigger it?

Hauke

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
