From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Wed, 3 Sep 2003 15:15:33 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309031318270.5039-100000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0309030900530.14208-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <yoshfuji@linux-ipv6.org>,
   <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309030900530.14208-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003, Pekka Savola wrote:

> On Tue, 2 Sep 2003, Ville Nuorvala wrote:
> >
> > ipv6_generate_eui64() derives the interface identifier from the MAC
> > address on ARPHRD_{ETHER,FDDI,IEEE802_TR,ARCNET} interfaces, but doesn't
> > do anything for other types of devices
>
> Ok, but then the command should be:
>
> /* try to inherit MAC address from another device, to build an EUI64 */

Ok, I'll update the comment :)

> > If the node doesn't have an Ethernet (etc.) NIC it won't get a valid
> > identifier from ipv6_generate_eui64() and has to resort to something
> > else, for example generating a random address.
>
> And exactly how often does this happen? Eth (all variants), FDDI, TR,
> ARCnet.. what's missing?  Does IPv6 even work with any other physical
> interfaces? :-)

Not perhaps physical, but PPP for example. Can we assume _all_ devices
have an Eth, FDDI, TR or ARCnet NIC? I would say no.

> Note: it is desirable to have link-local addresses reasonably stable.
> Randomizing them may not be the right choice.

They will of course be configured only once when the interface is brought
up :)

-Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
