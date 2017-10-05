From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH v3 1/2] dt-bindings: add device tree binding
 for Allwinner XR819 SDIO Wi-Fi
Date: Thu, 05 Oct 2017 09:58:01 +0300
Message-ID: <878tgq5beu.fsf@codeaurora.org>
References: <20171003165944.13056-1-icenowy@aosc.io>
	<20171003165944.13056-2-icenowy@aosc.io>
	<871smjxp46.fsf@kamboji.qca.qualcomm.com>
	<E46F3A20-294A-497E-AF71-C77A67AFDB8C@aosc.io>
	<59D4B1C8.8020105@broadcom.com> <20171004101145.kgjufpcktodppuy3@flea>
	<C4895259-FCDE-4B21-BB15-8F150FC53BE3@aosc.io>
Reply-To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,  devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Return-path: <linux-sunxi+bncBCQYFH77QIORBAFQ27HAKGQE7JVVBTA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <C4895259-FCDE-4B21-BB15-8F150FC53BE3-h8G6r0blFSE@public.gmane.org> (Icenowy Zheng's
	message of "Wed, 04 Oct 2017 18:15:11 +0800")
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org> writes:

> =E4=BA=8E 2017=E5=B9=B410=E6=9C=884=E6=97=A5 GMT+08:00 =E4=B8=8B=E5=8D=88=
6:11:45, Maxime Ripard
> <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> =E5=86=99=E5=88=B0:
>>On Wed, Oct 04, 2017 at 10:02:48AM +0000, Arend van Spriel wrote:
>>> On 10/4/2017 11:03 AM, Icenowy Zheng wrote:
>>> >=20
>>> >=20
>>> > =E4=BA=8E 2017=E5=B9=B410=E6=9C=884=E6=97=A5 GMT+08:00 =E4=B8=8B=E5=
=8D=885:02:17, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
>>=E5=86=99=E5=88=B0:
>>> > > Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org> writes:
>>> > >=20
>>> > > > Allwinner XR819 is a SDIO Wi-Fi chip, which has the
>>functionality to
>>> > > use
>>> > > > an out-of-band interrupt pin instead of SDIO in-band interrupt.
>>> > > >=20
>>> > > > Add the device tree binding of this chip, in order to make it
>>> > > possible
>>> > > > to add this interrupt pin to device trees.
>>> > > >=20
>>> > > > Signed-off-by: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
>>> > > > Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>> > > > ---
>>> > > > Changes in v3:
>>> > > > - Renames the node name.
>>> > > > - Adds ACK from Rob.
>>> > > > Changes in v2:
>>> > > > - Removed status property in example.
>>> > > > - Added required property reg.
>>> > > >=20
>>> > > >   .../bindings/net/wireless/allwinner,xr819.txt      | 38
>>> > > ++++++++++++++++++++++
>>> > > >   1 file changed, 38 insertions(+)
>>> > > >   create mode 100644
>>> > >
>>Documentation/devicetree/bindings/net/wireless/allwinner,xr819.txt
>>> > >=20
>>> > > Like I asked already last time, AFAICS there is no upstream xr819
>>> > > wireless driver in drivers/net/wireless directory. Do we still
>>accept
>>> > > bindings like this for out-of-tree drivers?
>>> >=20
>>> > See esp8089.
>>> >=20
>>> > There's also no in-tree driver for it.
>>>=20
>>> The question is whether we should. The above might be a precedent,
>>but it
>>> may not necessarily be the way to go. The commit message for esp8089
>>seems
>>> to hint that there is intent to have an in-tree driver:
>>>=20
>>> """
>>>     Note that at this point there only is an out of tree driver for
>>this
>>>     hardware, there is no clear timeline / path for merging this.
>>Still
>>>     I believe it would be good to specify the binding for this in
>>tree
>>>     now, so that any future migration to an in tree driver will not
>>cause
>>>     compatiblity issues.
>>>=20
>>>     Cc: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>>     Signed-off-by: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>     Signed-off-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>>> """
>>>=20
>>> Regardless the bindings are in principle independent of the kernel
>>and just
>>> describing hardware. I think there have been discussions to move the
>>> bindings to their own repository, but apparently it was decided
>>otherwise.
>>
>>Yeah, I guess especially how it could be merged with the cw1200 driver
>>would be very relevant to that commit log.
>
> The cw1200 driver seems to still have some legacy platform
> data. Maybe they should also be convert to DT.
> (Or maybe compatible =3D "allwinner,xr819" is enough, as
> xr819 is a specified variant of cw1200 family)

Ah, so the upstream cw1200 driver supports xr819? Has anyone tested
that? Or does cw1200 more changes than just adding the DT support?

--=20
Kalle Valo

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
