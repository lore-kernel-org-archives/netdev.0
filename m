From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.12-rc3-mm1
Date: Sat, 30 Apr 2005 03:38:18 -0700
Message-ID: <20050430033818.06b94e26.akpm@osdl.org>
References: <20050429231653.32d2f091.akpm@osdl.org>
	<42735E42.9050901@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
	netfilter-devel@lists.netfilter.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261184AbVD3KjI@vger.kernel.org>
To: Brice Goglin <Brice.Goglin@ens-lyon.org>
In-Reply-To: <42735E42.9050901@ens-lyon.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin <Brice.Goglin@ens-lyon.org> wrote:
>
> Andrew Morton a =E9crit :
>  > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.=
12-rc3/2.6.12-rc3-mm1/
>=20
>  Hi Andrew,
>=20
>  dmesg is flooded with these messages when lo is up.
>  I don't remember having ever seen this before.
>  My .config is attached.
>  Any idea ?
>=20
>  Thanks,
>  Brice
>=20
>=20
>=20
>  PROTO=3D6 127.0.0.1:53809 127.0.0.1:631 L=3D52 S=3D0x00 I=3D41505 F=3D=
0x4000 T=3D64
>  ip_local_deliver: bad loopback skb: PRE_ROUTING LOCAL_IN
>  skb: pf=3D2 (unowned) dev=3Dlo len=3D274
>  PROTO=3D6 127.0.0.1:631 127.0.0.1:53809 L=3D274 S=3D0x00 I=3D15075 F=
=3D0x4000 T=3D64
>  ip_local_deliver: bad loopback skb: PRE_ROUTING LOCAL_IN
>  skb: pf=3D2 (unowned) dev=3Dlo len=3D52
>  PROTO=3D6 127.0.0.1:53809 127.0.0.1:631 L=3D52 S=3D0x00 I=3D41507 F=3D=
0x4000 T=3D64
>  ip_local_deliver: bad loopback skb: PRE_ROUTING LOCAL_IN
>  skb: pf=3D2 (unowned) dev=3Dlo len=3D69

Beats me.  Someone broke netfilter ;)

Turning off CONFIG_NETFILTER_DEBUG should shut the warnings up.
