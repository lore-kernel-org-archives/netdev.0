From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/6] net: stmmac: support future possible
 different internal phy mode
Date: Thu, 29 Jun 2017 16:05:13 -0400 (EDT)
Message-ID: <20170629.160513.1064622973584891732.davem@davemloft.net>
References: <20170627092806.28181-1-clabbe.montjoie@gmail.com>
	<20170629.122349.2265868886957558079.davem@davemloft.net>
	<20170629170238.GA2606@Red>
Reply-To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
 maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
 alexandre.torgue-qxv4g6HH51o@public.gmane.org, andre.przywara-5wv7dgnIgG8@public.gmane.org,
 devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-sunxi+bncBCFPF2XH6UDBB7F22XFAKGQEDAONZPY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170629170238.GA2606@Red>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 29 Jun 2017 19:02:38 +0200

> On Thu, Jun 29, 2017 at 12:23:49PM -0400, David Miller wrote:
>> From: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Tue, 27 Jun 2017 11:28:01 +0200
>> =

>> > The current way to find if the phy is internal is to compare DT ph=
y-mode
>> > and emac_variant/internal_phy.
>> > But it will negate a possible future SoC where an external PHY use=
 the
>> > same phy mode than the internal one.
>> > =

>> > By using phy-mode =3D "internal" we permit to have an external PHY=
 with
>> > the same mode than the internal one.
>> > =

>> > Reported-by: Andr=E9 Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
>> > Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> =

>> Series applied.
>> =

>> Please provide a proper "[PATCH 0/n] " header posting next time.
> =

> Sorry could you wait for applying, there are a parallel thread (http:=
//www.spinics.net/lists/devicetree/msg183520.html) and it seems finaly =
that internal could not be the good way to do it.
> =

> Regards
> Sorry again, I should have sent a comment for waiting.

Please send me a revert patch, when I say I've applied it I already pus=
hed
it out to my GIT tree.
