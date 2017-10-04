From: "'Arend van Spriel' via linux-sunxi" <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Subject: Re: [PATCH v3 1/2] dt-bindings: add device tree binding
 for Allwinner XR819 SDIO Wi-Fi
Date: Wed, 4 Oct 2017 12:02:48 +0200
Message-ID: <59D4B1C8.8020105@broadcom.com>
References: <20171003165944.13056-1-icenowy@aosc.io>
 <20171003165944.13056-2-icenowy@aosc.io>
 <871smjxp46.fsf@kamboji.qca.qualcomm.com>
 <E46F3A20-294A-497E-AF71-C77A67AFDB8C@aosc.io>
Reply-To: arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
 Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-sunxi+bncBDRYNGWEWYDBBTHD2LHAKGQEICXCU3Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <E46F3A20-294A-497E-AF71-C77A67AFDB8C-h8G6r0blFSE@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 10/4/2017 11:03 AM, Icenowy Zheng wrote:
>
>
> =E4=BA=8E 2017=E5=B9=B410=E6=9C=884=E6=97=A5 GMT+08:00 =E4=B8=8B=E5=8D=88=
5:02:17, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> =E5=86=99=E5=88=B0:
>> Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org> writes:
>>
>>> Allwinner XR819 is a SDIO Wi-Fi chip, which has the functionality to
>> use
>>> an out-of-band interrupt pin instead of SDIO in-band interrupt.
>>>
>>> Add the device tree binding of this chip, in order to make it
>> possible
>>> to add this interrupt pin to device trees.
>>>
>>> Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
>>> Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>> ---
>>> Changes in v3:
>>> - Renames the node name.
>>> - Adds ACK from Rob.
>>> Changes in v2:
>>> - Removed status property in example.
>>> - Added required property reg.
>>>
>>>   .../bindings/net/wireless/allwinner,xr819.txt      | 38
>> ++++++++++++++++++++++
>>>   1 file changed, 38 insertions(+)
>>>   create mode 100644
>> Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
>>
>> Like I asked already last time, AFAICS there is no upstream xr819
>> wireless driver in drivers/net/wireless directory. Do we still accept
>> bindings like this for out-of-tree drivers?
>
> See esp8089.
>
> There's also no in-tree driver for it.

The question is whether we should. The above might be a precedent, but=20
it may not necessarily be the way to go. The commit message for esp8089=20
seems to hint that there is intent to have an in-tree driver:

"""
     Note that at this point there only is an out of tree driver for this
     hardware, there is no clear timeline / path for merging this. Still
     I believe it would be good to specify the binding for this in tree
     now, so that any future migration to an in tree driver will not cause
     compatiblity issues.

     Cc: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
     Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
     Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
"""

Regardless the bindings are in principle independent of the kernel and=20
just describing hardware. I think there have been discussions to move=20
the bindings to their own repository, but apparently it was decided=20
otherwise.

Regards,
Arend

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
