From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Thu, 15 Jan 2004 17:34:50 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401151719160.29722@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0401151537000.29722@rhea.tcs.hut.fi>
 <20040116.000117.133662773.yoshfuji@linux-ipv6.org>
 <Pine.LNX.4.58.0401151705500.29722@rhea.tcs.hut.fi>
 <20040116.001317.73950271.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040116.001317.73950271.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 16 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> net/ipv4/arp.c:
> | *              Alan Cox        :       Don't proxy across hardware ty=
pes!
>
> This implies that proxy works across devices and
> it is NOT what the "proxy" does in rfc2461.

Yes, as Pekka said, Thaler's proxy is like proxy ARP.

The proxy in rfc2461 is different. It is just a router that responds to
Neighbor Discovery queries on behalf of another node on the link.

The problem is that the ND queries may be both multicast and unicast.

In the current implementation the proxying router captures the multicast
queries since it has joined the solicited-node multicast group, but it
doesn't capture the unicast queries.

This is what I want to fix.

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
