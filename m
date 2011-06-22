From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH] MAINTAINERS: Remove Sven Eckelmann from
	BATMAN ADVANCED
Date: Wed, 22 Jun 2011 22:58:01 +0200
Message-ID: <2867331.bNPR7zso8k@sven-desktop.home.narfation.org>
References: <1308661983-4113-1-git-send-email-sven@narfation.org>
	<28453742.RFlbu1Gcpv@sven-desktop.home.narfation.org>
	<20110622.011620.1019772975075064501.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart9918459.7MH3XqzQJB";
	micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20110622.011620.1019772975075064501.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart9918459.7MH3XqzQJB
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday 22 June 2011 01:16:20 David Miller wrote:
> From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
> Date: Wed, 22 Jun 2011 09:41:45 +0200
> 
> > On Tuesday 21 June 2011 14:35:15 David Miller wrote:
> >> All of this effort was placed to get this thing merged into the
> >> main tree, and then moved out of staging.
> > 
> > "Shooting the messenger" - I think that is the matching phrase. Just try
> > to grep my name in the net/batman-adv/ and you will see it nowhere.
> 
> It is everywhere as far as I am concerned, because you're the only person
> actually keeping upstream maintained and in sync.

That is more related to the fact that Mareks opinion on the topic is that only 
one person should be in responsible for the linux merging and this position 
should not be changed each time. And I understood the names in MAINTAINERS as 
the persons which feel responsible and are the right ones to contact to get 
something done (whether it is merging, submitting bug reports, asking for 
information, ...).

> > The problem is that I am probably the most unimportant person in the
> > whole project.
> 
> From my perspective, this is not true.  You are the most important
> person.  And this is because the people writing the code obviously
> don't care enough about upstream to do any merges themselves.  Yet
> you do.

I think that I have to adjust your perspective slightly. I would never say 
that Marek doesn't care about something. Yes, he never did a pull request, but 
he always comes up and try to give further insight when it was needed. He is 
currently the mastermind behind batman-adv and tries to keep everything 
together.

He already wrote you that he is willing to take over and I will assist him as 
good as I can (but not doing pull request anymore or giving statements whether 
a patch is good or bad for batman-adv/linux)

Just to give you a small overview about the stuff where currently work is done 
(as far as I know). More or less the complete protocol should be rewritten and 
many features should be added. You already got the first step when you merged 
the translation table and roaming changes [1]. Other topics seem to be:
 * multicast[2]
 * splitting OGMs[3] in ELP[4], OGM and something else
 * Adding support for an ARP protocol over distributed hash tables[5]
 * wireless network coding[7]
 * ap isolation
 * mesh wide minstrel
 * transmission quality calculated using the data from the wifi drivers along
   the path
 * redundancy bonding
 * ...

Every change needs some modifications to the packet format and may make it 
incompatible to the previous versions (some only add flags and some need to 
modify many things and even add new packet types). They already started to 
discuss[8] how they want to send those changes to you.

thanks,
	Sven


[1] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2011-June/005010.html
[2] http://www.open-mesh.org/wiki/batman-adv/Multicast-ideas
[3] http://www.open-mesh.org/wiki/batman-adv/OGM
[4] http://www.open-mesh.org/wiki/batman-adv/ELP
[5] http://www.open-mesh.org/wiki/batman-adv/DAT
[6] http://www.open-mesh.org/wiki/batman-adv/MGO
[7] http://downloads.open-mesh.org/batman/misc/wbmv4-network_coding.avi
    (there is a document called "Inter-Flow Network Coding for Wireless Mesh
     Networks" about it, but I don't think that I am allowed to redistribute
     it)
[8] https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2011-June/005025.html
--nextPart9918459.7MH3XqzQJB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJOAldZAAoJEF2HCgfBJntGPhcQAMDG+p4hvZHKk0gy2vW914SM
98cinWb1XEsMFI/3VIYqZBpe6chzW0RH03mXt2OMCXcJhTJxVr8XTXy1uKfyqb6l
wfwhwK+LAdk9j2SQ9+aaAV2QyleC9oAt3TmVIm3GOic/u75TC33L7W7hm9zn+9cP
HB2434LQ2i3fIZU89F/wy9snMzUOXH2GhOgqovUUxRsOhIdMUo1hqHOfeqTJRXfW
3PG/YDyWTE6hMBsRJ8spGZXd0K2MRwY2C4d9E8DNFAz2B96I9QEn55DAIu5W57rI
3xexqT0VPA7lwokhc0ABpumEx6QJvKbhRqamezf7FmVTjp3DL/5MYGoPhGXcKDzg
ij21g2pZAqMOXgo2+LJApXD2XuQooLem6dj9JjfpZUArFkYoYrorW46tFx2ih86i
2o2GyaU4ySrmYZ2P1g1aYJ+byV+b4gLrhOakZqeA/B/ZW0vzkV9cjpJ+jMQGqgYo
+dWMF/xYeHFFTSsLLN0snPAp7+RC/ZZZmT7xQPZECdMQ8KnOG07//N26kIBAnp0S
qeEFNK9nIdsjFvB/n6paGOWSAwsLRu/yumtD6um0bPp8DitVITw7eK9N1BpYh6md
dUerv0itErOsZTVwf5TxitDj9MilulQreGmIXV6CQ1mkrrbdKtzxOy6o++Oq84ra
EmkNkSSRXTxVZdY6+Ccg
=TdPb
-----END PGP SIGNATURE-----

--nextPart9918459.7MH3XqzQJB--
