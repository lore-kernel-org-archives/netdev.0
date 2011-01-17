From: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 12:20:52 +0100
Message-ID: <201101171220.52292.florian@openwrt.org>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com> <1295261783.24530.3.camel@maggie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael =?utf-8?q?B=C3=BCsch?= <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1295261783.24530.3.camel@maggie>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 17 January 2011 11:56:23 Michael B=C3=BCsch wrote:
> On Mon, 2011-01-17 at 11:46 +0100, Jonas Gorski wrote:
> > Hello,
> >=20
> > I am currently looking into adding support for the newer Broadcom
> > BCM47xx/53xx SoCs. They require having HND/AI support, which probab=
ly
> > means merging the current SSB code and the HND/AI code from the
> > brcm80211 driver. Is anyone already working on this?
> >=20
> > As far as I can see, there are two possibilities:
> >=20
> > a) Merge the HND/AI code into the current SSB code, or
> >=20
> > b) add the missing code for SoCs to brcm80211 and replace the SSB c=
ode
> > with it.
>=20
> Why can't we keep those two platforms separated?

That is also what I am wondering about. Considering that previous BCM47=
xx=20
platforms use a MIPS4k core and newer one use MIPS74k or later, you wou=
ld not=20
be able to build a single kernel for both which takes advantages of com=
pile-
time optimizations targetting MIPS74k. If this ist not a big concern, t=
hen=20
let's target a single kernel.

> Is there really a lot of shared code between SSB and HND/AI?
>=20
> It's true that there's currently a lot of device functionality built
> into ssb. Like pci bridge, mips core, extif, etc...
> If you take all that code out, you're probably not left with anything=
=2E
>=20
> So why do we need to replace or merge SSB in the first place? Can't
> it co-exist with HND/AI?
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
