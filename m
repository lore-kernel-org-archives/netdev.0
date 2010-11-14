From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: a Great Idea - include Kademlia networking protocol in
 kernel -- REVISITED
Date: Sun, 14 Nov 2010 09:50:43 +0100
Message-ID: <1289724643.2743.58.camel@edumazet-laptop>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
	 <AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Guerin <stephen@sfcomplex.org>
To: Marcos <stalkingtime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43874 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989Ab0KNIuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 03:50:51 -0500
Received: by wwb29 with SMTP id 29so315714wwb.1
        for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 00:50:49 -0800 (PST)
In-Reply-To: <AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 14 novembre 2010 =C3=A0 00:21 -0700, Marcos a =C3=A9crit :
> [Fwd from [linux-kernel], thought I'd follow the suggestion to post
> this to netdev:]
>=20
> After seeing some attention this idea generated in the linux press,
> I'd like to re-visit this suggestion.  I'm a nobody on this list, but
> do have some expertise in complex systems (i.e. complexity theory).
>=20
> The Kademlia protocol is simple: it has four commands (and won't
> likely grow more): PING, STORE, FIND_NODE, FIND_VALUE.
> It is computationally effortless: it generates random node id's and
> computes distance on a distributed hash table using an simple XOR
> function.
> It is (probably optimally) efficient:  O(log(n)) for n nodes.
> Ultimately, it could increase security: by creating a system for
> tracking trusted peers, a new topology of content-sharing can be
> generated.
>=20
> [From the (kademlia) wikipedia article]: "The first generation peer-t=
o-peer file
> sharing networks, such as Napster, relied on a central database to
> co-ordinate look ups on the network. Second generation peer-to-peer
> networks, such as Gnutella, used flooding to locate files, searching
> every node on the network. Third generation peer-to-peer networks use
> Distributed Hash Tables to look up files in the network. Distributed
> hash tables store resource locations throughout the network. A major
> criterion for these protocols is locating the desired nodes quickly."
>=20
> Putting a simple, but robust p2p network layer in the kernel offers
> several novel and very interesting possibilities.
>=20
> 1. Cutting-edge cool factor:  It would put linux way ahead of the
> net's general evolution to an full-fledged "Internet Operating
> System".  The world needs an open source solution over Google's,
> Microsoft's (or any other's) attempt to create such a solution.
> Dismiss any attempts to see such a request as warez-d00ds looking to
> make a more efficient pirating network.
>=20
> 2. Lower maintenance:  Though unification, it would simplify the many
> (currently disparate) linux solutions for large-scale aggregation of
> computational and storage resources that are distributed across many
> machines.  Additionally, NFS (the networking protocol that *IS* in th=
e
> kernel) is stale, has high administrative and operational overhead,
> and is not made to scale to millions of shared nodes in a graph
> topology.
>=20
> 3. Excite a new wave of Linux development:  90% of linux machines are
> on the net, but don't utilize the real value of peer connectivity
> (which can grow profoundly faster than Metcalf's N^2 "value of the
> network" law).  Putting p2p in kernel space communicates to every
> developer that linux is serious about creating a unified and complete
> solution for creating such a infrastructure.  Let the cloud
> applications and such be in user space, but keep the main
> connection-tracking in the kernel.   Such a move would make for many
> (unforeseeable) complex emergent behaviors and optimizations to arise
> -- see Wikipedia on Reed's Law for a sense of it (to wit: "even if th=
e
> utility of groups available to be joined is very small on a peer-grou=
p
> basis, eventually the network effect of potential group membership ..=
=2E
> dominate[s] the overall economics of the system").
>=20
> Consider, for example, social networking: it is an inherently p2p
> structure and is lying in wait to explode the next wave of internet
> evolution and new-value generation.  There's no doubt that this is th=
e
> trend of the future -- best that open source be there first.  Users
> are creating value on their machines *every day*, but there's little
> infrastructure to take advantage of it.  Currently, it's either lost
> or exploited.  Solution and vision trajectories:  Diaspora comes to
> mind, mash-up applications like Photosynth aggregating the millions o=
f
> photos on people's computers (see the TED.com presentation), open
> currencies and meritocratic market systems using such a "meta-linux"
> as a backbone, etc. -- whole new governance models for sharing conten=
t
> would undoubtedly arise.  HTTP/HTML is too much of an all-or-nothing
> and coarse approach to organizing the world's content.  The net needs
> a backbone for sharing personal content and grouping it to create new
> abstractions and wealth.  See pangaia.sourceforge.net for some of
> ideas I've personally been developing.
>=20
> Anyway, I'm with hp_fk on this one.  Ignore at the peril and risk of
> the future...  :)
>=20

I have no idea why and how kademlia would be added to "linux kernel"

Its a protocol based on UDP, and probably already done on userland.

What am I missing ?



