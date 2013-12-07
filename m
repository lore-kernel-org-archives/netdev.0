From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH 02/10] net: stmmac: Honor DT parameter to
 force DMA store and forward mode
Date: Sat, 7 Dec 2013 09:19:55 +0800
Message-ID: <CAGb2v64WAV_xWNuneKZr0=7g8_=G5_q5hFax2+8xJiopnm3uPg@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-3-git-send-email-wens@csie.org> <20131206.162606.2277176361893801778.davem@davemloft.net>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=001a11c3e47ca62b1c04ece790b0
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Srinivas KANDAGATLA <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>, maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBBT7PRGKQKGQEW6XXUMQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20131206.162606.2277176361893801778.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

--001a11c3e47ca62b1c04ece790b0
Content-Type: text/plain; charset=ISO-8859-1

On Sat, Dec 7, 2013 at 5:26 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> Date: Sat,  7 Dec 2013 01:29:35 +0800
>
>> @@ -47,6 +47,7 @@ static int stmmac_probe_config_dt(struct
platform_device *pdev,
>>               plat->bus_id = 0;
>>
>>       of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr);
>> +     plat->force_sf_dma_mode = of_property_read_bool(np,
"snps,force_sf_dma_mode");
>
> Will this do the right thing for when the property is not present?
> Right now the force_sf_dma_mode value is always false.

of_property_read_bool will return false when the property is not present.

> In fact won't it override the explicit settings done elsewhere in the
> driver?

Point taken. The current implementation will override settings passed from
platform data. ORing the two would be better.


Thanks

-- 
You received this message because you are subscribed to the Google Groups "linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/groups/opt_out.

--001a11c3e47ca62b1c04ece790b0
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><span style=3D"font-family:courier new,monospace"><br=
>On Sat, Dec 7, 2013 at 5:26 AM, David Miller &lt;<a href=3D"mailto:davem@d=
avemloft.net">davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org</a>&gt; wrote:<br>&gt; From: Chen-Yu Tsai=
 &lt;<a href=3D"mailto:wens-jdAy2FN1RRM@public.gmane.org">wens-jdAy2FN1RRM@public.gmane.org</a>&gt;<br>

&gt; Date: Sat, =A07 Dec 2013 01:29:35 +0800<br>&gt;<br>&gt;&gt; @@ -47,6 +=
47,7 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,<br>=
&gt;&gt; =A0 =A0 =A0 =A0 =A0 =A0 =A0 plat-&gt;bus_id =3D 0;<br>&gt;&gt;<br>=
&gt;&gt; =A0 =A0 =A0 of_property_read_u32(np, &quot;snps,phy-addr&quot;, &a=
mp;plat-&gt;phy_addr);<br>

&gt;&gt; + =A0 =A0 plat-&gt;force_sf_dma_mode =3D of_property_read_bool(np,=
 &quot;snps,force_sf_dma_mode&quot;);<br>&gt;<br>&gt; Will this do the righ=
t thing for when the property is not present?<br>&gt; Right now the force_s=
f_dma_mode value is always false.<br>

<br>of_property_read_bool will return false when the property is not presen=
t.<br><br>&gt; In fact won&#39;t it override the explicit settings done els=
ewhere in the<br>&gt; driver?<br><br>Point taken. The current implementatio=
n will override settings passed from<br>

platform data. ORing the two would be better.<br><br><br></span></div><span=
 style=3D"font-family:courier new,monospace">Thanks<br></span></div>

<p></p>

-- <br />
You received this message because you are subscribed to the Google Groups &=
quot;linux-sunxi&quot; group.<br />
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org<br />
For more options, visit <a href=3D"https://groups.google.com/groups/opt_out=
">https://groups.google.com/groups/opt_out</a>.<br />

--001a11c3e47ca62b1c04ece790b0--
