From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPV6][NDISC] unify ipv6 output routine
Date: Fri, 6 Feb 2004 19:48:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206194844.42bebb59.davem@redhat.com>
References: <200402070232.33771.kazunori@miyazawa.org>
	<4023D6FB.9010909@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kazunori@miyazawa.org, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika =?ISO-8859-1?Q?Penttil=E4?= <mika.penttila@kolumbus.fi>
In-Reply-To: <4023D6FB.9010909@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 06 Feb 2004 20:03:39 +0200
Mika Penttil=E4 <mika.penttila@kolumbus.fi> wrote:

> >Yoshifuji-san and I send the patch which unifies IPv6 output routine a=
nd remove
> >RTF_NDISC again. It resolves an issue of IPv6 IPsec with neighbor disc=
overy
> >without a flag.
>=20
> You break multicast replies, see what ndisc_build_ll_hdr() does...

That's right, and compiler should have warned about ndisc_build_ll_hdr()
(a static function in ndisc.c) since it was no longer referenced after
applying the patch, which would be a clue that something was wrong :-)
