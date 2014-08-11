From: "Ankit ." <learnertilldeath@gmail.com>
Subject: Re: [PATCH] drivers: fixed spelling of "celcius" to "celsius"
Date: Tue, 12 Aug 2014 08:00:01 +0900
Message-ID: <CAKscYYz-Nyiu7hX9rEVLmXrf1+=gZafE2rd6eB0c6ZaTRMQSDw@mail.gmail.com>
References: <1407571352-33867-1-git-send-email-learnertilldeath@gmail.com>
 <CAC-25o-qMVTsZ=pvXNDJGKTsubGd_sfVJ6AJmsov=Nrz3o9VxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1926097040=="
Cc: shahed.shaikh@qlogic.com,
 "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, netdev@vger.kernel.org,
 sre@kernel.org, dri-devel@lists.freedesktop.org,
 LKML <linux-kernel@vger.kernel.org>,
 Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
 Zhang Rui <rui.zhang@intel.com>, David Woodhouse <dwmw2@infradead.org>
To: "edubezval@gmail.com" <edubezval@gmail.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <CAC-25o-qMVTsZ=pvXNDJGKTsubGd_sfVJ6AJmsov=Nrz3o9VxQ@mail.gmail.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

--===============1926097040==
Content-Type: multipart/alternative; boundary=001a11c1c3e0ccd32705006283d6

--001a11c1c3e0ccd32705006283d6
Content-Type: text/plain; charset=UTF-8

Hello Eduardo

Thank you for the advice. This is my first attempt so apologies if I made
some mistake.
I will send changes separately for each domain.

Thanks
Ankit


On Sun, Aug 10, 2014 at 1:49 AM, edubezval@gmail.com <edubezval@gmail.com>
wrote:

> Hello Ankit,
>
> On Sat, Aug 9, 2014 at 4:02 AM, Ankit <learnertilldeath@gmail.com> wrote:
> > Fixed spelling issue -- changed celcius to celsius
> >
> > Kernel version: mainline
> >
> > Signed-off-by: Ankit <learnertilldeath@gmail.com>
>
> On the thermal part,
>
> Acked-by: Eduardo Valentin <edubezval@gmail.com>
>
> but I think might be worth splitting the change per domain, so we
> avoid merge conflicts. The change is just one liner though.
>
> > ---
> >  drivers/gpu/drm/nouveau/core/engine/graph/nv10.c  | 4 ++--
> >  drivers/gpu/drm/nouveau/core/engine/graph/nv20.c  | 2 +-
> >  drivers/gpu/drm/nouveau/core/engine/graph/nv25.c  | 2 +-
> >  drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 +-
> >  drivers/power/ds2780_battery.c                    | 2 +-
> >  drivers/power/ds2782_battery.c                    | 2 +-
> >  drivers/thermal/thermal_core.c                    | 2 +-
> >  7 files changed, 8 insertions(+), 8 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
> b/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
> > index 4532f7e..1faeeb1 100644
> > --- a/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
> > +++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c
> > @@ -451,7 +451,7 @@ nv10_graph_sclass[] = {
> >         { 0x0093, &nv04_graph_ofuncs }, /* surf3d */
> >         { 0x0094, &nv04_graph_ofuncs }, /* ttri */
> >         { 0x0095, &nv04_graph_ofuncs }, /* mtri */
> > -       { 0x0056, &nv04_graph_ofuncs }, /* celcius */
> > +       { 0x0056, &nv04_graph_ofuncs }, /* celsius */
> >         {},
> >  };
> >
> > @@ -474,7 +474,7 @@ nv15_graph_sclass[] = {
> >         { 0x0093, &nv04_graph_ofuncs }, /* surf3d */
> >         { 0x0094, &nv04_graph_ofuncs }, /* ttri */
> >         { 0x0095, &nv04_graph_ofuncs }, /* mtri */
> > -       { 0x0096, &nv04_graph_ofuncs }, /* celcius */
> > +       { 0x0096, &nv04_graph_ofuncs }, /* celsius */
> >         {},
> >  };
> >
> > diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
> b/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
> > index d145e08..eb00689 100644
> > --- a/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
> > +++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c
> > @@ -31,7 +31,7 @@ nv20_graph_sclass[] = {
> >         { 0x0072, &nv04_graph_ofuncs, NULL }, /* beta4 */
> >         { 0x0089, &nv04_graph_ofuncs, NULL }, /* sifm */
> >         { 0x008a, &nv04_graph_ofuncs, NULL }, /* ifc */
> > -       { 0x0096, &nv04_graph_ofuncs, NULL }, /* celcius */
> > +       { 0x0096, &nv04_graph_ofuncs, NULL }, /* celsius */
> >         { 0x0097, &nv04_graph_ofuncs, NULL }, /* kelvin */
> >         { 0x009e, &nv04_graph_ofuncs, NULL }, /* swzsurf */
> >         { 0x009f, &nv04_graph_ofuncs, NULL }, /* imageblit */
> > diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
> b/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
> > index 7a80d00..fcfe1c5 100644
> > --- a/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
> > +++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c
> > @@ -28,7 +28,7 @@ nv25_graph_sclass[] = {
> >         { 0x0072, &nv04_graph_ofuncs, NULL }, /* beta4 */
> >         { 0x0089, &nv04_graph_ofuncs, NULL }, /* sifm */
> >         { 0x008a, &nv04_graph_ofuncs, NULL }, /* ifc */
> > -       { 0x0096, &nv04_graph_ofuncs, NULL }, /* celcius */
> > +       { 0x0096, &nv04_graph_ofuncs, NULL }, /* celsius */
> >         { 0x009e, &nv04_graph_ofuncs, NULL }, /* swzsurf */
> >         { 0x009f, &nv04_graph_ofuncs, NULL }, /* imageblit */
> >         { 0x0597, &nv04_graph_ofuncs, NULL }, /* kelvin */
> > diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> > index f5786d5..b0f7ab0 100644
> > --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> > +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
> > @@ -1264,7 +1264,7 @@ static ssize_t qlcnic_hwmon_show_temp(struct
> device *dev,
> >                 value = QLC_SHARED_REG_RD32(adapter, QLCNIC_ASIC_TEMP);
> >
> >         temperature = qlcnic_get_temp_val(value);
> > -       /* display millidegree celcius */
> > +       /* display millidegree celsius */
> >         temperature *= 1000;
> >         return sprintf(buf, "%u\n", temperature);
> >  }
> > diff --git a/drivers/power/ds2780_battery.c
> b/drivers/power/ds2780_battery.c
> > index 9f418fa..bf7d4bd 100644
> > --- a/drivers/power/ds2780_battery.c
> > +++ b/drivers/power/ds2780_battery.c
> > @@ -210,7 +210,7 @@ static int ds2780_get_temperature(struct
> ds2780_device_info *dev_info,
> >                 return ret;
> >
> >         /*
> > -        * Temperature is measured in units of 0.125 degrees celcius, the
> > +        * Temperature is measured in units of 0.125 degrees celsius, the
> >          * power_supply class measures temperature in tenths of degrees
> >          * celsius. The temperature value is stored as a 10 bit number,
> plus
> >          * sign in the upper bits of a 16 bit register.
> > diff --git a/drivers/power/ds2782_battery.c
> b/drivers/power/ds2782_battery.c
> > index 041f9b6..adc7d32 100644
> > --- a/drivers/power/ds2782_battery.c
> > +++ b/drivers/power/ds2782_battery.c
> > @@ -104,7 +104,7 @@ static int ds278x_get_temp(struct ds278x_info *info,
> int *temp)
> >         int err;
> >
> >         /*
> > -        * Temperature is measured in units of 0.125 degrees celcius, the
> > +        * Temperature is measured in units of 0.125 degrees celsius, the
> >          * power_supply class measures temperature in tenths of degrees
> >          * celsius. The temperature value is stored as a 10 bit number,
> plus
> >          * sign in the upper bits of a 16 bit register.
> > diff --git a/drivers/thermal/thermal_core.c
> b/drivers/thermal/thermal_core.c
> > index 71b0ec0..e69db4f 100644
> > --- a/drivers/thermal/thermal_core.c
> > +++ b/drivers/thermal/thermal_core.c
> > @@ -691,7 +691,7 @@ passive_store(struct device *dev, struct
> device_attribute *attr,
> >         if (!sscanf(buf, "%d\n", &state))
> >                 return -EINVAL;
> >
> > -       /* sanity check: values below 1000 millicelcius don't make sense
> > +       /* sanity check: values below 1000 millicelsius don't make sense
> >          * and can cause the system to go into a thermal heart attack
> >          */
> >         if (state && state < 1000)
> > --
> > 1.8.3.4 (Apple Git-47)
> >
>
>
>
> --
> Eduardo Bezerra Valentin
>

--001a11c1c3e0ccd32705006283d6
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div><div>Hello Eduardo<br><br></div>Thank you for th=
e advice. This is my first attempt so apologies if I made some mistake.<br>=
</div>I will send changes separately for each domain.<br><br></div>Thanks<b=
r>
Ankit<br></div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote=
">On Sun, Aug 10, 2014 at 1:49 AM, <a href=3D"mailto:edubezval@gmail.com">e=
dubezval@gmail.com</a> <span dir=3D"ltr">&lt;<a href=3D"mailto:edubezval@gm=
ail.com" target=3D"_blank">edubezval@gmail.com</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">Hello Ankit,<br>
<div class=3D""><br>
On Sat, Aug 9, 2014 at 4:02 AM, Ankit &lt;<a href=3D"mailto:learnertilldeat=
h@gmail.com">learnertilldeath@gmail.com</a>&gt; wrote:<br>
&gt; Fixed spelling issue -- changed celcius to celsius<br>
&gt;<br>
&gt; Kernel version: mainline<br>
&gt;<br>
&gt; Signed-off-by: Ankit &lt;<a href=3D"mailto:learnertilldeath@gmail.com"=
>learnertilldeath@gmail.com</a>&gt;<br>
<br>
</div>On the thermal part,<br>
<br>
Acked-by: Eduardo Valentin &lt;<a href=3D"mailto:edubezval@gmail.com">edube=
zval@gmail.com</a>&gt;<br>
<br>
but I think might be worth splitting the change per domain, so we<br>
avoid merge conflicts. The change is just one liner though.<br>
<div class=3D"HOEnZb"><div class=3D"h5"><br>
&gt; ---<br>
&gt; =C2=A0drivers/gpu/drm/nouveau/core/engine/graph/nv10.c =C2=A0| 4 ++--<=
br>
&gt; =C2=A0drivers/gpu/drm/nouveau/core/engine/graph/nv20.c =C2=A0| 2 +-<br=
>
&gt; =C2=A0drivers/gpu/drm/nouveau/core/engine/graph/nv25.c =C2=A0| 2 +-<br=
>
&gt; =C2=A0drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 +-<br>
&gt; =C2=A0drivers/power/ds2780_battery.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 2 +-<br>
&gt; =C2=A0drivers/power/ds2782_battery.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 2 +-<br>
&gt; =C2=A0drivers/thermal/thermal_core.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 2 +-<br>
&gt; =C2=A07 files changed, 8 insertions(+), 8 deletions(-)<br>
&gt;<br>
&gt; diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c b/driver=
s/gpu/drm/nouveau/core/engine/graph/nv10.c<br>
&gt; index 4532f7e..1faeeb1 100644<br>
&gt; --- a/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c<br>
&gt; +++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv10.c<br>
&gt; @@ -451,7 +451,7 @@ nv10_graph_sclass[] =3D {<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0093, &amp;nv04_graph_ofuncs }, /* sur=
f3d */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0094, &amp;nv04_graph_ofuncs }, /* ttr=
i */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0095, &amp;nv04_graph_ofuncs }, /* mtr=
i */<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 { 0x0056, &amp;nv04_graph_ofuncs }, /* celcius =
*/<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 { 0x0056, &amp;nv04_graph_ofuncs }, /* celsius =
*/<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 {},<br>
&gt; =C2=A0};<br>
&gt;<br>
&gt; @@ -474,7 +474,7 @@ nv15_graph_sclass[] =3D {<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0093, &amp;nv04_graph_ofuncs }, /* sur=
f3d */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0094, &amp;nv04_graph_ofuncs }, /* ttr=
i */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0095, &amp;nv04_graph_ofuncs }, /* mtr=
i */<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 { 0x0096, &amp;nv04_graph_ofuncs }, /* celcius =
*/<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 { 0x0096, &amp;nv04_graph_ofuncs }, /* celsius =
*/<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 {},<br>
&gt; =C2=A0};<br>
&gt;<br>
&gt; diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c b/driver=
s/gpu/drm/nouveau/core/engine/graph/nv20.c<br>
&gt; index d145e08..eb00689 100644<br>
&gt; --- a/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c<br>
&gt; +++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv20.c<br>
&gt; @@ -31,7 +31,7 @@ nv20_graph_sclass[] =3D {<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0072, &amp;nv04_graph_ofuncs, NULL }, =
/* beta4 */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0089, &amp;nv04_graph_ofuncs, NULL }, =
/* sifm */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x008a, &amp;nv04_graph_ofuncs, NULL }, =
/* ifc */<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 { 0x0096, &amp;nv04_graph_ofuncs, NULL }, /* ce=
lcius */<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 { 0x0096, &amp;nv04_graph_ofuncs, NULL }, /* ce=
lsius */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0097, &amp;nv04_graph_ofuncs, NULL }, =
/* kelvin */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x009e, &amp;nv04_graph_ofuncs, NULL }, =
/* swzsurf */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x009f, &amp;nv04_graph_ofuncs, NULL }, =
/* imageblit */<br>
&gt; diff --git a/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c b/driver=
s/gpu/drm/nouveau/core/engine/graph/nv25.c<br>
&gt; index 7a80d00..fcfe1c5 100644<br>
&gt; --- a/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c<br>
&gt; +++ b/drivers/gpu/drm/nouveau/core/engine/graph/nv25.c<br>
&gt; @@ -28,7 +28,7 @@ nv25_graph_sclass[] =3D {<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0072, &amp;nv04_graph_ofuncs, NULL }, =
/* beta4 */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0089, &amp;nv04_graph_ofuncs, NULL }, =
/* sifm */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x008a, &amp;nv04_graph_ofuncs, NULL }, =
/* ifc */<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 { 0x0096, &amp;nv04_graph_ofuncs, NULL }, /* ce=
lcius */<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 { 0x0096, &amp;nv04_graph_ofuncs, NULL }, /* ce=
lsius */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x009e, &amp;nv04_graph_ofuncs, NULL }, =
/* swzsurf */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x009f, &amp;nv04_graph_ofuncs, NULL }, =
/* imageblit */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 { 0x0597, &amp;nv04_graph_ofuncs, NULL }, =
/* kelvin */<br>
&gt; diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drive=
rs/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c<br>
&gt; index f5786d5..b0f7ab0 100644<br>
&gt; --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c<br>
&gt; +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c<br>
&gt; @@ -1264,7 +1264,7 @@ static ssize_t qlcnic_hwmon_show_temp(struct dev=
ice *dev,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 value =3D QLC_=
SHARED_REG_RD32(adapter, QLCNIC_ASIC_TEMP);<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 temperature =3D qlcnic_get_temp_val(value)=
;<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 /* display millidegree celcius */<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 /* display millidegree celsius */<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 temperature *=3D 1000;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 return sprintf(buf, &quot;%u\n&quot;, temp=
erature);<br>
&gt; =C2=A0}<br>
&gt; diff --git a/drivers/power/ds2780_battery.c b/drivers/power/ds2780_bat=
tery.c<br>
&gt; index 9f418fa..bf7d4bd 100644<br>
&gt; --- a/drivers/power/ds2780_battery.c<br>
&gt; +++ b/drivers/power/ds2780_battery.c<br>
&gt; @@ -210,7 +210,7 @@ static int ds2780_get_temperature(struct ds2780_de=
vice_info *dev_info,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;<br=
>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0* Temperature is measured in units of 0.1=
25 degrees celcius, the<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Temperature is measured in units of 0.1=
25 degrees celsius, the<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* power_supply class measures temper=
ature in tenths of degrees<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* celsius. The temperature value is =
stored as a 10 bit number, plus<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* sign in the upper bits of a 16 bit=
 register.<br>
&gt; diff --git a/drivers/power/ds2782_battery.c b/drivers/power/ds2782_bat=
tery.c<br>
&gt; index 041f9b6..adc7d32 100644<br>
&gt; --- a/drivers/power/ds2782_battery.c<br>
&gt; +++ b/drivers/power/ds2782_battery.c<br>
&gt; @@ -104,7 +104,7 @@ static int ds278x_get_temp(struct ds278x_info *inf=
o, int *temp)<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 int err;<br>
&gt;<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 =C2=A0* Temperature is measured in units of 0.1=
25 degrees celcius, the<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Temperature is measured in units of 0.1=
25 degrees celsius, the<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* power_supply class measures temper=
ature in tenths of degrees<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* celsius. The temperature value is =
stored as a 10 bit number, plus<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* sign in the upper bits of a 16 bit=
 register.<br>
&gt; diff --git a/drivers/thermal/thermal_core.c b/drivers/thermal/thermal_=
core.c<br>
&gt; index 71b0ec0..e69db4f 100644<br>
&gt; --- a/drivers/thermal/thermal_core.c<br>
&gt; +++ b/drivers/thermal/thermal_core.c<br>
&gt; @@ -691,7 +691,7 @@ passive_store(struct device *dev, struct device_at=
tribute *attr,<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!sscanf(buf, &quot;%d\n&quot;, &amp;st=
ate))<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EINVAL=
;<br>
&gt;<br>
&gt; - =C2=A0 =C2=A0 =C2=A0 /* sanity check: values below 1000 millicelcius=
 don&#39;t make sense<br>
&gt; + =C2=A0 =C2=A0 =C2=A0 /* sanity check: values below 1000 millicelsius=
 don&#39;t make sense<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* and can cause the system to go int=
o a thermal heart attack<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (state &amp;&amp; state &lt; 1000)<br>
&gt; --<br>
&gt; 1.8.3.4 (Apple Git-47)<br>
&gt;<br>
<br>
<br>
<br>
</div></div><span class=3D"HOEnZb"><font color=3D"#888888">--<br>
Eduardo Bezerra Valentin<br>
</font></span></blockquote></div><br></div>

--001a11c1c3e0ccd32705006283d6--

--===============1926097040==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
dri-devel mailing list
dri-devel@lists.freedesktop.org
http://lists.freedesktop.org/mailman/listinfo/dri-devel

--===============1926097040==--
