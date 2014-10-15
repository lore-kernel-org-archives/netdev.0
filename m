From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: Regarding tx-nocache-copy in the Sheevaplug
Date: Wed, 15 Oct 2014 14:57:01 -0700
Message-ID: <20141015215701.GA4109@f1.synalogic.ca>
References: <20141013105246.GD1972@vicerveza.homeunix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Carles =?iso-8859-1?Q?Pag=E8s?= <page@cubata.homelinux.net>,
	linux-arm-kernel@lists.infradead.org
To: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141013105246.GD1972@vicerveza.homeunix.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/10/13 12:52, Llu=EDs Batlle i Rossell wrote:
> Hello,
>=20
> on the 7th of January 2014 ths patch was applied:
> https://lkml.org/lkml/2014/1/7/307
>=20
> [PATCH v2] net: Do not enable tx-nocache-copy by default
>        =20
> In the Sheevaplug (ARM Feroceon 88FR131 from Marvell) this made packe=
ts to be
> sent corrupted. I think this machine has something special about the =
cache.
>=20
> Enabling back this tx-nocache-copy (as it used to be before the patch=
) the
> transfers work fine again. I think that most people, encountering thi=
s problem,
> completely disable the tx offload instead of enabling back this setti=
ng.
>=20
> Is this an ARM kernel problem regarding this platform?

This is odd, only x86 defines ARCH_HAS_NOCACHE_UACCESS. On arm,
skb_do_copy_data_nocache() should end up using __copy_from_user()
regardless of tx-nocache-copy.
