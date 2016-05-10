From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Tue, 10 May 2016 22:11:54 +0300
Message-ID: <5732327A.6080203@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com> <5732294F.3060606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5732294F.3060606-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/10/2016 09:32 PM, Florian Fainelli wrote:

>> The PHY devices sometimes do have their reset signal (maybe even power
>> supply?) tied to some GPIO and sometimes it also does happen that a boot
>> loader does not leave it deasserted. So far this issue has been attacked
>> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
>> the GPIO in question; that solution, when applied to the device trees, led
>> to adding the PHY reset GPIO properties to the MAC device node, with one
>> exception: Cadence MACB driver which could handle the "reset-gpios" prop
>> in a PHY device subnode. I believe that the correct approach is to teach
>> the 'phylib' to get the MDIO device reset GPIO from the device tree node
>> corresponding to this device -- which this patch is doing...
>>
>> Note that I had to modify the  AT803x PHY driver as it would stop working
>> otherwise as it made use of the reset GPIO for its own purposes...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
>
> This looks good to me:
>
> Acked-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

    Thank you! I'll send v3 without [RFT] then.

> Can you follow up with changes in phy_{suspend,resume}

    I'm not sure what changes you mean -- powering down the PHYs?

> if that is also
> an use case that you have?

    No, I'm not into power management.

MBR, Sergei

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
