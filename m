From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND
 support
Date: Thu, 15 Jan 2004 15:00:24 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401141726490.24125@rhea.tcs.hut.fi>
References: <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi>
 <20040114.210427.104284595.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: netfilter-devel@lists.netfilter.org, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040114.210427.104284595.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004, YOSHIFUJI Hideaki / [iso-2022-jp] =B5=C8=C6=A3=B1=D1=
=CC=C0 wrote:

> I don't think so. Proxy should not depend on netfilter.

That's not very constructive criticism, Yoshifuji-san ;)

There aren't that many ways of doing this "hack" cleanly.

The fact of the matter is: the proxy needs to scan through the unicast
packets to filter out the Neighbor Discovery packets, if it supports NUD.

I think a netfilter module is the cleanest way of doing this. It doesn't
change any interfaces either inside the kernel, or to userspace. As a
module this feature is also easy to turn on if you want it, and it doesn'=
t
cause any preformance penalties if you don't.

What kind of solution do you propose for this problem?

Regards,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
