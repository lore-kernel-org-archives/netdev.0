From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH|RFC] IPv6 netfilter: a module for complete proxy ND support
Date: Wed, 14 Jan 2004 13:25:42 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401141250470.24125@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netfilter-devel@lists.netfilter.org, davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello all,

a proxy needs to capture and process Neighbor Solicitations on behalf of
the proxied node. Normal multicast NS messages are already handled by the
existing neigbor discovery code, but unicast NS messages used for Neighbor
Unreachability Detection will only be handled by the proxy if it captures
the packets for local processing. I think the cleanest solution for this
is a netfilter module (which I have incidentally written already :)

The attached patch contains the afore mentioned module.

Any comments are welcome!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
