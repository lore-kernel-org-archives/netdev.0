From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: (usagi-core 17380) Re: [PATCH][IPV6][NDISC] unify ipv6 output
 routine
Date: Sat, 07 Feb 2004 20:29:56 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207.202956.74336171.yoshfuji@linux-ipv6.org>
References: <20040207.192804.29120956.yoshfuji@linux-ipv6.org>
	<4024C0EA.1010904@kolumbus.fi>
	<4024C1D5.5030906@kolumbus.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: kazunori@miyazawa.org, davem@redhat.com, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.penttila@kolumbus.fi
In-Reply-To: <4024C1D5.5030906@kolumbus.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4024C1D5.5030906@kolumbus.fi> (at Sat, 07 Feb 2004 12:45:41 +=
0200), Mika Penttil=E4 <mika.penttila@kolumbus.fi> says:

> >> I think you missed our ndsic_dst_alloc() change.
> >> ndisc_dst_alloc() takes 4 argument:
> >>   struct dst_entry *ndisc_dst_alloc(struct net_device *dev,=20
> >>                                     struct neighbour *neigh,
> >>                                     struct in6_addr *addr,
> >>                                     int (*output)(struct sk_buff *))=
;
> >> If neigh is NULL, we do ndisc_get_neigh(dev, addr) to get one.
> >>
> >> =20
> >>
> > hmm. where is this ndisc_dst_alloc() change? In the patch it's called=
=20
> > with three params, only the output routine is changed :
> >
> > - dst =3D ndisc_dst_alloc(dev, NULL, ndisc_output);
> > + dst =3D ndisc_dst_alloc(dev, NULL, ip6_output2);
:
> I see, it was in a follow-up patch. Ok, I was just looking at the=20
> original patch, which didn't work. But with this ndisc_dst_alloc()=20
> change it's ok.

Oh my god!!

Miyazawa-san failed to export our "correct" code in original patch.
I didn't noticed that.

We're sorry about it. Thank you for spotting the bug.

--=20
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
