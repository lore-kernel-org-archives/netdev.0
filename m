From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v3 1/2] dt-bindings: add device tree binding
 for Allwinner XR819 SDIO Wi-Fi
Date: Mon, 16 Oct 2017 15:58:20 +0300
Message-ID: <87o9p7meqb.fsf@kamboji.qca.qualcomm.com>
References: <20171003165944.13056-1-icenowy@aosc.io>
	<20171003165944.13056-2-icenowy@aosc.io>
	<871smjxp46.fsf@kamboji.qca.qualcomm.com>
	<E46F3A20-294A-497E-AF71-C77A67AFDB8C@aosc.io>
	<59D4B1C8.8020105@broadcom.com> <20171004101145.kgjufpcktodppuy3@flea>
	<C4895259-FCDE-4B21-BB15-8F150FC53BE3@aosc.io>
	<878tgq5beu.fsf@codeaurora.org>
	<dba5f095f9f25f0726ee3a2852e01b88@aosc.io>
Reply-To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,  netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,  linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,  Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,  Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,  Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,  linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: icenowy-h8G6r0blFSE@public.gmane.org
Return-path: <linux-sunxi+bncBCQYFH77QIORB46ZSLHQKGQEYXCGGKQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <dba5f095f9f25f0726ee3a2852e01b88-h8G6r0blFSE@public.gmane.org> (icenowy-h8G6r0blFSE@public.gmane.org's
	message of "Sat, 14 Oct 2017 20:00:52 +0800")
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

icenowy-h8G6r0blFSE@public.gmane.org writes:

>>>>> > > Like I asked already last time, AFAICS there is no upstream xr819
>>>>> > > wireless driver in drivers/net/wireless directory. Do we still
>>>> accept
>>>>> > > bindings like this for out-of-tree drivers?
>>>>> >
>>>>> > See esp8089.
>>>>> >
>>>>> > There's also no in-tree driver for it.
>>>>>
>>>>> The question is whether we should. The above might be a precedent,
>>>> but it
>>>>> may not necessarily be the way to go. The commit message for esp8089
>>>> seems
>>>>> to hint that there is intent to have an in-tree driver:
>>>>>
>>>>> """
>>>>>     Note that at this point there only is an out of tree driver for
>>>> this
>>>>>     hardware, there is no clear timeline / path for merging this.
>>>> Still
>>>>>     I believe it would be good to specify the binding for this in
>>>> tree
>>>>>     now, so that any future migration to an in tree driver will not
>>>> cause
>>>>>     compatiblity issues.
>>>>>
>>>>>     Cc: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>>>>     Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>>>     Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>>>> """
>>>>>
>>>>> Regardless the bindings are in principle independent of the kernel
>>>> and just
>>>>> describing hardware. I think there have been discussions to move the
>>>>> bindings to their own repository, but apparently it was decided
>>>> otherwise.
>>>>
>>>> Yeah, I guess especially how it could be merged with the cw1200
>>>> driver
>>>> would be very relevant to that commit log.
>>>
>>> The cw1200 driver seems to still have some legacy platform
>>> data. Maybe they should also be convert to DT.
>>> (Or maybe compatible = "allwinner,xr819" is enough, as
>>> xr819 is a specified variant of cw1200 family)
>>
>> Ah, so the upstream cw1200 driver supports xr819? Has anyone tested
>> that? Or does cw1200 more changes than just adding the DT support?
>
> The support of XR819 in CW1200 driver is far more difficult than I
> imagined -- the codedrop used in the mainlined CW1200 driver seems to
> be so old that it's before XR819 (which seems to be based on CW1160),
> and there's a large number of problems to adapt it to a modern CW1200
> variant.
>
> P.S. could you apply this device tree binding patch now?

As I haven't seen any consensus that applying bindings document for
out-of-tree drivers is ok so at least I'm not taking this. Though not
sure what DT maintainers are planning to do.

-- 
Kalle Valo
