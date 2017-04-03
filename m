From: Kiran Kumar <kiran1677-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [v10,
	7/7] mmc: sdhci-of-esdhc: fix host version for T4240-R1.0-R2.0
Date: Mon, 3 Apr 2017 19:46:01 +0530
Message-ID: <CAPbBx=6TrXKx5VmFvpz=_kak13vpUgqSkf-E3R22t5O4RJXKNg@mail.gmail.com>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com>
	<4448030.Zs8fVnr3nm@wuerfel>
	<HE1PR04MB0889B52134A43C0E7A452B7BF87C0@HE1PR04MB0889.eurprd04.prod.outlook.com>
	<5159406.HOFrj7pRfW@wuerfel>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5317013285928050936=="
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Qiang Zhao <qiang.zhao-3arQi8VN3Tc@public.gmane.org>, Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Bhupesh Sharma <bhupesh.sharma-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Scott Wood <oss-fOR+EgIDQEHk1uMJSBkQmQ@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Santosh Shilimkar <ssantosh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Xiaobo Xie <xiaobo.xie-3arQi8VN3Tc@public.gmane.org>, Yang-Leo Li <leoyang.li-3arQi8VN3Tc@public.gmane.org>,
	"iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <i
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <5159406.HOFrj7pRfW@wuerfel>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============5317013285928050936==
Content-Type: multipart/alternative; boundary=001a1148d476995c8c054c43ccf0

--001a1148d476995c8c054c43ccf0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Sorry to post in this huge email bunch.

I have most probably hit an errata in Freescale T4240 for
PPC_DISABLE_THREADS. I'm using Rev2 - T4240. Is this Errata required to be
taken care or not?  Any quick help is appreciated!

My issue: I'm running line rate of Traffic to T4240 [10G of traffic on each
port of capacity of 10G]; After few hours of running of traffic, My CPU/LMP
gets stuck and goes in for Hard reset. When I searched through the code and
some open forums, I saw the errata listed above. I'm not sure if that
errata works for me or not. I have pasted a snapshot of issue occuring in
my system

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

During hang, with Softlock up enabled, I get prints from smp_many ->
showing =E2=80=98every processor is waiting for processor 22=E2=80=99 ; I n=
eed to know what
happened to processor 22. The processor number keep changing every time
when I run the traffic.

Processor 22 goes into a deadlock state with interrupts disabled or it went
into a deep idle sleep state is the issue i feel.

If its deep idle state -> a NMI should have recovered it.

But if it=E2=80=99s a deadlock issue with interrupt disabled then I need to=
 know
the root cause for the deadlock.

*root@A@0-1-1:~# [ 1602.261011] Current::17 waiting::22 flag::4353 [
1602.720488] Current::14 waiting::22 flag::3585 [ 1602.756404] Current::15
waiting::22 flag::3841 [ 1604.903248] Current::16 waiting::22 flag::4097 [
1619.400917] Current::14 waiting::22 flag::3585 [ 1619.517870] Current::17
waiting::22 flag::4353 [ 1619.749893] Current::15 waiting::22 flag::3841 [
1619.798453] Current::4 waiting::22 flag::1025 [ 1622.177171] Current::16
waiting::22 flag::4097 [ 1622.449412] INFO: rcu_preempt detected stalls on
CPUs/tasks: { 22} (detected by 4, t=3D21008 jiffies, g=3D101651, c=3D101650=
,
q=3D4713) [ 1622.460951] Task dump for CPU 22:*

*[ 1622.464275] swapper/22      R  running task        0     0      1
0x00000800*

*[ 1622.471355] Call Trace:*

*[ 1622.473820] [c0000001f92b78d0] [000000000000009e] 0x9e (unreliable) [
1622.480119] [c0000001f92b7960] [c0000001f92b7aa0] 0xc0000001f92b7aa0 [
1622.486497] [c0000001f92b79e0] [c000000000a90275] 0xc000000000a90275 [
1622.492878] [c0000001f92b7a60] [c000000000006f64] .do_IRQ+0x184/0x370 [
1622.499344] [c0000001f92b7b10] [c00000000001b93c]
exc_0x500_common+0xfc/0x100 [ 1622.506539] --- Exception: 501 at
0xc000000000a3e200*

*[ 1622.506539]     LR =3D .__check_irq_replay+0x68/0x110*

*[ 1622.516388] [c0000001f92b7e00] [c0000000000bc590]
.cpu_startup_entry+0x1d0/0x350 (unreliable) [ 1622.524950]
[c0000001f92b7ed0] [c000000000a00460] .start_secondary+0x3ec/0x3f4 [
1622.532197] [c0000001f92b7f90] [c00000000000036c]
.start_secondary_prolog+0x10/0x14 [ 1635.237829] Current::3 waiting::5
flag::769 [ 1636.587746] Current::14 waiting::22 flag::3585 [ 1637.082117]
Current::17 waiting::22 flag::4353 [ 1637.224920] Current::4 waiting::22
flag::1025 [ 1637.268789] Current::15 waiting::22 flag::3841 [ 1640.085792]
Current::16 waiting::22 flag::4097 [ 1651.093367] Current::4 waiting::22
flag::1025*

*=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D*

Regards,

Kiran

On Thu, May 5, 2016 at 4:40 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:

> On Thursday 05 May 2016 09:41:32 Yangbo Lu wrote:
> > > -----Original Message-----
> > > From: Arnd Bergmann [mailto:arnd-r2nGTMty4D4@public.gmane.org]
> > > Sent: Thursday, May 05, 2016 4:32 PM
> > > To: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> > > Cc: Yangbo Lu; linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > > linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > > linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org
> > > foundation.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Mark Rutland;
> > > ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org; Russell King; Bhupesh Sharma; Joerg Roedel;
> > > Santosh Shilimkar; Yang-Leo Li; Scott Wood; Rob Herring; Claudiu
> Manoil;
> > > Kumar Gala; Xiaobo Xie; Qiang Zhao
> > > Subject: Re: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for
> T4240-
> > > R1.0-R2.0
> > >
> > > On Thursday 05 May 2016 11:12:30 Yangbo Lu wrote:
> > > >
> > > > +       fsl_guts_init();
> > > > +       svr =3D fsl_guts_get_svr();
> > > > +       if (svr) {
> > > > +               esdhc->soc_ver =3D SVR_SOC_VER(svr);
> > > > +               esdhc->soc_rev =3D SVR_REV(svr);
> > > > +       } else {
> > > > +               dev_err(&pdev->dev, "Failed to get SVR value!\n");
> > > > +       }
> > > > +
> > > >
> > >
> > >
> > > Sorry for jumping in again after not participating in the discussion
> for
> > > the past few versions.
> > >
> > > What happened to my suggestion of making this a platform-independent
> > > interface to avoid the link time dependency?
> > >
> > > Specifically, why not add an exported function to drivers/base/soc.c
> that
> > > uses glob_match() for comparing a string in the device driver to the =
ID
> > > of the SoC that is set by whatever SoC identifying driver the platfor=
m
> > > has?
> >
> > [Lu Yangbo-B47093] I think this has been discussed in v6.
> > You can find Scott's comments about this in below link.
> > https://patchwork.kernel.org/patch/8544501/
>
> Ah, thanks for bearing with me and digging this out again. Let me follow
> up on Scott's older replies here then:
>
> > >> IIRC, it is the same IP block as i.MX and Arnd's point is this won't
> > >> even compile on !PPC. It is things like this that prevent sharing th=
e
> > >> driver.
> >
> > The whole point of using the MMIO SVR instead of the PPC SPR is so that
> > it will work on ARM...  The guts driver should build on any platform as
> > long as OF is enabled, and if it doesn't find a node to bind to it will
> > return 0 for SVR, and the eSDHC driver will continue (after printing an
> > error that should be removed) without the ability to test for errata
> > based on SVR.
>
> It feels like a bad design to have to come up with a different
> method for each SoC type here when they all do the same thing
> and want to identify some variant of the chip to do device
> specific quirks.
>
> As far as I'm concerned, every driver in drivers/soc that needs to
> export a symbol to be used by a device driver is an indication that
> we don't have the right set of abstractions yet. There are cases
> that are not worth abstracting because the functionality is rather
> obscure and only a couple of drivers for one particular chip
> ever need it.
>
> Finding out the version of the SoC does not look like this case.
>
> > > I think the first four patches take care of building for ARM,
> > > but the problem remains if you want to enable COMPILE_TEST as
> > > we need for certain automated checking.
> >
> > What specific problem is there with COMPILE_TEST?
>
> COMPILE_TEST is solvable here and the way it is implemented in this
> case (selecting FSL_GUTS from the driver) indeed looks like it works
> correctly, but it's still awkward that this means building the
> SoC specific ID stuff into the vmlinux binary for any driver that
> uses something like that for a particular SoC.
>
> > >> Dealing with Si revs is a common problem. We should have a
> > >> common solution. There is soc_device for this purpose.
> > >
> > > Exactly. The last time this came up, I think we agreed to implement a
> > > helper using glob_match() on the soc_device strings. Unfortunately
> > > this hasn't happened then, but I'd still prefer that over yet another
> > > vendor-specific way of dealing with the generic issue.
> >
> > soc_device would require encoding the SVR as a string and then decoding
> > the string, which is more complicated and error prone than having
> > platform-specific code test a platform-specific number.
>
> You already need to encode it as a string to register the soc_device,
> and the driver just needs to pass a glob string, so the only part that
> is missing is the generic function that takes the string from the
> driver and passes that to glob_match for the soc_device.
>
> > And when would it get registered on arm64, which doesn't have
> > platform code?
>
> Whenever the soc driver is loaded, as is the case now. The match
> function can return -EPROBE_DEFER if no SoC device is registered
> yet.
>
>         Arnd
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
>

--001a1148d476995c8c054c43ccf0
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Sorry to post in this huge email bunch.<div><br></div><div=
>I have most probably hit an errata in Freescale T4240 for PPC_DISABLE_THRE=
ADS. I&#39;m using Rev2 - T4240. Is this Errata required to be taken care o=
r not?=C2=A0 Any quick help is appreciated!=C2=A0</div><div><br></div><div>=
My issue: I&#39;m running line rate of Traffic to T4240 [10G of traffic on =
each port of capacity of 10G]; After few hours of running of traffic, My CP=
U/LMP gets stuck and goes in for Hard reset. When I searched through the co=
de and some open forums, I saw the errata listed above. I&#39;m not sure if=
 that errata works for me or not. I have pasted a snapshot of issue occurin=
g in my system</div><div><br></div><div>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D</div><div><p class=3D"gmail-MsoListParagraph"><spa=
n style=3D"font-size:11pt;font-family:calibri,sans-serif;color:rgb(31,73,12=
5)">During hang, with Softlock up enabled, I get prints from smp_many -&gt;
showing =E2=80=98every processor is waiting for processor 22=E2=80=99 ; I n=
eed to know what
happened to processor 22. The processor number keep changing every time whe=
n I run the traffic.<span></span></span></p>

<p class=3D"gmail-MsoListParagraph"><span style=3D"color:rgb(31,73,125);fon=
t-family:calibri,sans-serif;font-size:11pt">Processor 22 goes into a deadlo=
ck
state with interrupts disabled or it went into a deep idle sleep state is t=
he
issue i feel.</span><br></p>

<p class=3D"gmail-MsoListParagraph"><span style=3D"font-size:11pt;font-fami=
ly:calibri,sans-serif;color:rgb(31,73,125)">If its deep idle state -&gt; a =
NMI
should have recovered it.<span></span></span></p>

<p class=3D"gmail-MsoListParagraph"><span style=3D"font-size:11pt;font-fami=
ly:calibri,sans-serif;color:rgb(31,73,125)">But if it=E2=80=99s a deadlock =
issue with
interrupt disabled then I need to know the root cause for the deadlock.<spa=
n></span></span></p>

<p class=3D"gmail-MsoListParagraph"><i><span style=3D"font-size:11pt;font-f=
amily:calibri,sans-serif;color:rgb(31,73,125)">root@A@0-1-1:~# [
1602.261011] Current::17 waiting::22 flag::4353 [ 1602.720488] Current::14
waiting::22 flag::3585 [ 1602.756404] Current::15 waiting::22 flag::3841 [
1604.903248] Current::16 waiting::22 flag::4097 [ 1619.400917] Current::14
waiting::22 flag::3585 [ 1619.517870] Current::17 waiting::22 flag::4353 [
1619.749893] Current::15 waiting::22 flag::3841 [ 1619.798453] Current::4
waiting::22 flag::1025 [ 1622.177171] Current::16 waiting::22 flag::4097 [
1622.449412] INFO: rcu_preempt detected stalls on CPUs/tasks: { 22} (detect=
ed
by 4, t=3D21008 jiffies, g=3D101651, c=3D101650, q=3D4713) [ 1622.460951] T=
ask dump for
CPU 22:<span></span></span></i></p>

<p class=3D"gmail-MsoListParagraph"><i><span style=3D"font-size:11pt;font-f=
amily:calibri,sans-serif;color:rgb(31,73,125)">[ 1622.464275]
swapper/22=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 R=C2=A0 running
task=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 0=C2=A0=C2=A0=C2=A0=C2=A0
0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 1 0x00000800<span></span></span></i></p>

<p class=3D"gmail-MsoListParagraph"><i><span style=3D"font-size:11pt;font-f=
amily:calibri,sans-serif;color:rgb(31,73,125)">[ 1622.471355] Call Trace:<s=
pan></span></span></i></p>

<p class=3D"gmail-MsoListParagraph"><i><span style=3D"font-size:11pt;font-f=
amily:calibri,sans-serif;color:rgb(31,73,125)">[ 1622.473820] [c0000001f92b=
78d0]
[000000000000009e] 0x9e (unreliable) [ 1622.480119] [c0000001f92b7960]
[c0000001f92b7aa0] 0xc0000001f92b7aa0 [ 1622.486497] [c0000001f92b79e0]
[c000000000a90275] 0xc000000000a90275 [ 1622.492878] [c0000001f92b7a60]
[c000000000006f64] .do_IRQ+0x184/0x370 [ 1622.499344] [c0000001f92b7b10]
[c00000000001b93c] exc_0x500_common+0xfc/0x100 [ 1622.506539] --- Exception=
:
501 at 0xc000000000a3e200<span></span></span></i></p>

<p class=3D"gmail-MsoListParagraph"><i><span style=3D"font-size:11pt;font-f=
amily:calibri,sans-serif;color:rgb(31,73,125)">[
1622.506539]=C2=A0=C2=A0=C2=A0=C2=A0 LR =3D .__check_irq_replay+0x68/0x110<=
span></span></span></i></p>

<p class=3D"gmail-MsoListParagraph"><i><span style=3D"font-size:11pt;font-f=
amily:calibri,sans-serif;color:rgb(31,73,125)">[ 1622.516388] [c0000001f92b=
7e00]
[c0000000000bc590] .cpu_startup_entry+0x1d0/0x350 (unreliable) [ 1622.52495=
0]
[c0000001f92b7ed0] [c000000000a00460] .start_secondary+0x3ec/0x3f4 [
1622.532197] [c0000001f92b7f90] [c00000000000036c]
.start_secondary_prolog+0x10/0x14 [ 1635.237829] Current::3 waiting::5
flag::769 [ 1636.587746] Current::14 waiting::22 flag::3585 [ 1637.082117]
Current::17 waiting::22 flag::4353 [ 1637.224920] Current::4 waiting::22
flag::1025 [ 1637.268789] Current::15 waiting::22 flag::3841 [ 1640.085792]
Current::16 waiting::22 flag::4097 [ 1651.093367] Current::4 waiting::22
flag::1025</span></i><span style=3D"font-size:11pt;font-family:calibri,sans=
-serif;color:rgb(31,73,125)"><span></span></span></p><p class=3D"gmail-MsoL=
istParagraph"><i><span style=3D"font-size:11pt;font-family:calibri,sans-ser=
if;color:rgb(31,73,125)">=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D</span></i></p>=
<p class=3D"gmail-MsoListParagraph"><font color=3D"#1f497d" face=3D"calibri=
, sans-serif"><span style=3D"font-size:14.6667px">Regards,</span></font></p=
><p class=3D"gmail-MsoListParagraph"><font color=3D"#1f497d" face=3D"calibr=
i, sans-serif"><span style=3D"font-size:14.6667px">Kiran</span></font></p><=
/div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">On Thu=
, May 5, 2016 at 4:40 PM, Arnd Bergmann <span dir=3D"ltr">&lt;<a href=3D"ma=
ilto:arnd-r2nGTMty4D4@public.gmane.org" target=3D"_blank">arnd-r2nGTMty4D4@public.gmane.org</a>&gt;</span> wrote:<b=
r><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:=
1px #ccc solid;padding-left:1ex"><div class=3D"HOEnZb"><div class=3D"h5">On=
 Thursday 05 May 2016 09:41:32 Yangbo Lu wrote:<br>
&gt; &gt; -----Original Message-----<br>
&gt; &gt; From: Arnd Bergmann [mailto:<a href=3D"mailto:arnd-r2nGTMty4D4@public.gmane.org">arnd=
@arndb.de</a>]<br>
&gt; &gt; Sent: Thursday, May 05, 2016 4:32 PM<br>
&gt; &gt; To: <a href=3D"mailto:linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org">linuxppc-dev=
@lists.ozlabs.org</a><br>
&gt; &gt; Cc: Yangbo Lu; <a href=3D"mailto:linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">linux=
-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a>; <a href=3D"mailto:devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">dev=
icetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a>;<br>
&gt; &gt; <a href=3D"mailto:linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org">linux-arm=
-kernel@lists.<wbr>infradead.org</a>; <a href=3D"mailto:linux-kernel@vger.k=
ernel.org">linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a>;<br>
&gt; &gt; <a href=3D"mailto:linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">linux-clk-u79uwXL29TZNg+MwTxZMZA@public.gmane.org=
l.org</a>; <a href=3D"mailto:linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">linux-i2c-u79uwXL29Tb/PtFMR13I2A@public.gmane.org=
el.org</a>; iommu-cunTk1MwBs/ROKNJybVBZg@public.gmane.org<br>
&gt; &gt; <a href=3D"http://foundation.org" rel=3D"noreferrer" target=3D"_b=
lank">foundation.org</a>; <a href=3D"mailto:netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">netdev@=
vger.kernel.org</a>; Mark Rutland;<br>
&gt; &gt; <a href=3D"mailto:ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org">ulf.hansson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org<=
/a>; Russell King; Bhupesh Sharma; Joerg Roedel;<br>
&gt; &gt; Santosh Shilimkar; Yang-Leo Li; Scott Wood; Rob Herring; Claudiu =
Manoil;<br>
&gt; &gt; Kumar Gala; Xiaobo Xie; Qiang Zhao<br>
&gt; &gt; Subject: Re: [v10, 7/7] mmc: sdhci-of-esdhc: fix host version for=
 T4240-<br>
&gt; &gt; R1.0-R2.0<br>
&gt; &gt;<br>
&gt; &gt; On Thursday 05 May 2016 11:12:30 Yangbo Lu wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0fsl_guts_init();<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0svr =3D fsl_guts_get_svr();<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0if (svr) {<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0esdh=
c-&gt;soc_ver =3D SVR_SOC_VER(svr);<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0esdh=
c-&gt;soc_rev =3D SVR_REV(svr);<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0} else {<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dev_=
err(&amp;pdev-&gt;dev, &quot;Failed to get SVR value!\n&quot;);<br>
&gt; &gt; &gt; +=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
&gt; &gt; &gt; +<br>
&gt; &gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt;<br>
&gt; &gt; Sorry for jumping in again after not participating in the discuss=
ion for<br>
&gt; &gt; the past few versions.<br>
&gt; &gt;<br>
&gt; &gt; What happened to my suggestion of making this a platform-independ=
ent<br>
&gt; &gt; interface to avoid the link time dependency?<br>
&gt; &gt;<br>
&gt; &gt; Specifically, why not add an exported function to drivers/base/so=
c.c that<br>
&gt; &gt; uses glob_match() for comparing a string in the device driver to =
the ID<br>
&gt; &gt; of the SoC that is set by whatever SoC identifying driver the pla=
tform<br>
&gt; &gt; has?<br>
&gt;<br>
</div></div><span class=3D"">&gt; [Lu Yangbo-B47093] I think this has been =
discussed in v6.<br>
&gt; You can find Scott&#39;s comments about this in below link.<br>
&gt; <a href=3D"https://patchwork.kernel.org/patch/8544501/" rel=3D"norefer=
rer" target=3D"_blank">https://patchwork.kernel.org/<wbr>patch/8544501/</a>=
<br>
<br>
</span>Ah, thanks for bearing with me and digging this out again. Let me fo=
llow<br>
up on Scott&#39;s older replies here then:<br>
<br>
&gt; &gt;&gt; IIRC, it is the same IP block as i.MX and Arnd&#39;s point is=
 this won&#39;t<br>
&gt; &gt;&gt; even compile on !PPC. It is things like this that prevent sha=
ring the<br>
&gt; &gt;&gt; driver.<br>
&gt;<br>
&gt; The whole point of using the MMIO SVR instead of the PPC SPR is so tha=
t<br>
&gt; it will work on ARM...=C2=A0 The guts driver should build on any platf=
orm as<br>
&gt; long as OF is enabled, and if it doesn&#39;t find a node to bind to it=
 will<br>
&gt; return 0 for SVR, and the eSDHC driver will continue (after printing a=
n<br>
&gt; error that should be removed) without the ability to test for errata<b=
r>
&gt; based on SVR.<br>
<br>
It feels like a bad design to have to come up with a different<br>
method for each SoC type here when they all do the same thing<br>
and want to identify some variant of the chip to do device<br>
specific quirks.<br>
<br>
As far as I&#39;m concerned, every driver in drivers/soc that needs to<br>
export a symbol to be used by a device driver is an indication that<br>
we don&#39;t have the right set of abstractions yet. There are cases<br>
that are not worth abstracting because the functionality is rather<br>
obscure and only a couple of drivers for one particular chip<br>
ever need it.<br>
<br>
Finding out the version of the SoC does not look like this case.<br>
<br>
&gt; &gt; I think the first four patches take care of building for ARM,<br>
&gt; &gt; but the problem remains if you want to enable COMPILE_TEST as<br>
&gt; &gt; we need for certain automated checking.<br>
&gt;<br>
&gt; What specific problem is there with COMPILE_TEST?<br>
<br>
COMPILE_TEST is solvable here and the way it is implemented in this<br>
case (selecting FSL_GUTS from the driver) indeed looks like it works<br>
correctly, but it&#39;s still awkward that this means building the<br>
SoC specific ID stuff into the vmlinux binary for any driver that<br>
uses something like that for a particular SoC.<br>
<br>
&gt; &gt;&gt; Dealing with Si revs is a common problem. We should have a<br=
>
&gt; &gt;&gt; common solution. There is soc_device for this purpose.<br>
&gt; &gt;<br>
&gt; &gt; Exactly. The last time this came up, I think we agreed to impleme=
nt a<br>
&gt; &gt; helper using glob_match() on the soc_device strings. Unfortunatel=
y<br>
&gt; &gt; this hasn&#39;t happened then, but I&#39;d still prefer that over=
 yet another<br>
&gt; &gt; vendor-specific way of dealing with the generic issue.<br>
&gt;<br>
&gt; soc_device would require encoding the SVR as a string and then decodin=
g<br>
&gt; the string, which is more complicated and error prone than having<br>
&gt; platform-specific code test a platform-specific number.<br>
<br>
You already need to encode it as a string to register the soc_device,<br>
and the driver just needs to pass a glob string, so the only part that<br>
is missing is the generic function that takes the string from the<br>
driver and passes that to glob_match for the soc_device.<br>
<br>
&gt; And when would it get registered on arm64, which doesn&#39;t have<br>
&gt; platform code?<br>
<br>
Whenever the soc driver is loaded, as is the case now. The match<br>
function can return -EPROBE_DEFER if no SoC device is registered<br>
yet.<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 Arnd<br>
</font></span><div class=3D"HOEnZb"><div class=3D"h5">_____________________=
_________<wbr>_________________<br>
Linuxppc-dev mailing list<br>
<a href=3D"mailto:Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org">Linuxppc-dev-uLR06cmDAlaKREJ1Ck/qmQ@public.gmane.org=
org</a><br>
<a href=3D"https://lists.ozlabs.org/listinfo/linuxppc-dev" rel=3D"noreferre=
r" target=3D"_blank">https://lists.ozlabs.org/<wbr>listinfo/linuxppc-dev</a=
></div></div></blockquote></div><br></div>

--001a1148d476995c8c054c43ccf0--

--===============5317013285928050936==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============5317013285928050936==--
