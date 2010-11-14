From: Marcos <stalkingtime@gmail.com>
Subject: Fwd: a Great Idea - include Kademlia networking protocol in kernel -- REVISITED
Date: Sun, 14 Nov 2010 00:21:40 -0700
Message-ID: <AANLkTinWUmQ91cCULC8ZXFLwSKz6SNt3BpszrBEhbgcu@mail.gmail.com>
References: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Guerin <stephen@sfcomplex.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45412 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753614Ab0KNHVm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 02:21:42 -0500
Received: by bwz15 with SMTP id 15so4331196bwz.19
        for <netdev@vger.kernel.org>; Sat, 13 Nov 2010 23:21:40 -0800 (PST)
In-Reply-To: <AANLkTi=VgBQ5rwkjZeo2zsRx1dSBy+4PBXeLLPQ4LRES@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Fwd from [linux-kernel], thought I'd follow the suggestion to post
this to netdev:]

After seeing some attention this idea generated in the linux press,
I'd like to re-visit this suggestion. =A0I'm a nobody on this list, but
do have some expertise in complex systems (i.e. complexity theory).

The Kademlia protocol is simple: it has four commands (and won't
likely grow more): PING, STORE, FIND_NODE, FIND_VALUE.
It is computationally effortless: it generates random node id's and
computes distance on a distributed hash table using an simple XOR
function.
It is (probably optimally) efficient: =A0O(log(n)) for n nodes.
Ultimately, it could increase security: by creating a system for
tracking trusted peers, a new topology of content-sharing can be
generated.

[From the (kademlia) wikipedia article]: "The first generation peer-to-=
peer file
sharing networks, such as Napster, relied on a central database to
co-ordinate look ups on the network. Second generation peer-to-peer
networks, such as Gnutella, used flooding to locate files, searching
every node on the network. Third generation peer-to-peer networks use
Distributed Hash Tables to look up files in the network. Distributed
hash tables store resource locations throughout the network. A major
criterion for these protocols is locating the desired nodes quickly."

Putting a simple, but robust p2p network layer in the kernel offers
several novel and very interesting possibilities.

1. Cutting-edge cool factor: =A0It would put linux way ahead of the
net's general evolution to an full-fledged "Internet Operating
System". =A0The world needs an open source solution over Google's,
Microsoft's (or any other's) attempt to create such a solution.
Dismiss any attempts to see such a request as warez-d00ds looking to
make a more efficient pirating network.

2. Lower maintenance: =A0Though unification, it would simplify the many
(currently disparate) linux solutions for large-scale aggregation of
computational and storage resources that are distributed across many
machines. =A0Additionally, NFS (the networking protocol that *IS* in th=
e
kernel) is stale, has high administrative and operational overhead,
and is not made to scale to millions of shared nodes in a graph
topology.

3. Excite a new wave of Linux development: =A090% of linux machines are
on the net, but don't utilize the real value of peer connectivity
(which can grow profoundly faster than Metcalf's N^2 "value of the
network" law). =A0Putting p2p in kernel space communicates to every
developer that linux is serious about creating a unified and complete
solution for creating such a infrastructure. =A0Let the cloud
applications and such be in user space, but keep the main
connection-tracking in the kernel. =A0 Such a move would make for many
(unforeseeable) complex emergent behaviors and optimizations to arise
-- see Wikipedia on Reed's Law for a sense of it (to wit: "even if the
utility of groups available to be joined is very small on a peer-group
basis, eventually the network effect of potential group membership ...
dominate[s] the overall economics of the system").

Consider, for example, social networking: it is an inherently p2p
structure and is lying in wait to explode the next wave of internet
evolution and new-value generation. =A0There's no doubt that this is th=
e
trend of the future -- best that open source be there first. =A0Users
are creating value on their machines *every day*, but there's little
infrastructure to take advantage of it. =A0Currently, it's either lost
or exploited. =A0Solution and vision trajectories: =A0Diaspora comes to
mind, mash-up applications like Photosynth aggregating the millions of
photos on people's computers (see the TED.com presentation), open
currencies and meritocratic market systems using such a "meta-linux"
as a backbone, etc. -- whole new governance models for sharing content
would undoubtedly arise. =A0HTTP/HTML is too much of an all-or-nothing
and coarse approach to organizing the world's content. =A0The net needs
a backbone for sharing personal content and grouping it to create new
abstractions and wealth. =A0See pangaia.sourceforge.net for some of
ideas I've personally been developing.

Anyway, I'm with hp_fk on this one. =A0Ignore at the peril and risk of
the future... =A0:)

marcos
