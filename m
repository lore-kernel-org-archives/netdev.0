From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 1 Aug 2006 13:00:03 +0100
Message-ID: <20060801120003.GY8334@innerghost.net>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net> <200608010231.58339.ak@suse.de> <20060731.174641.99457765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XZLT0nNRngx3qG4/"
Cc: ak@suse.de, herbert@gondor.apana.org.au, kazunori@miyazawa.org,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:14552 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S1750761AbWHAMAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:00:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060731.174641.99457765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--XZLT0nNRngx3qG4/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

David,

> To drive this home even more, I do not believe that the people who
> advocate pushing NDISC and ARP policy into userspace would be very
> happy if something like the RAID transformations were moved into
> userspace and they were not able to access their disks if the RAID
> transformer process in userspace died.

   How would you restart the RAID controller daemon if it's stored
 in the RAID itself? Also, assuming the same code quality (and ignoring
 OOM killer for a moment), if the RAID controller daemon dies, if that
 code was in the kernel, it would also possibly crash the whole kernel.

> At that point, network access equals disk access.  It would be amusing
> to need to restart such an NDISC/ARP daemon if it were to live on a
> remote volume. :-)

   What you are saying is that, well, the NDISC handling is already in
 the host's memory (kernel text), so the connection could be restarted
 with the remote storage facility. So, let's be fair, and say that
 somehow the NDISC daemon would be available localy?

> I understand full well that on special purpose network devices this
> control vs. data plane seperation into userspace might make a lot of
> sense.  But for a general purpose operating system, such as Linux, the
> greater concern is resiliency to failures and each piece of core
> functionality you move to userspace is a new potential point of
> failure.

   I think 100% of Linux's users want stability. Resiliency to failure
 is not something that depends on the kernel. If the code in question is
 in the kernel, and it crashes, how will you recover?

   Please note that i'm not making this a monolithic vs. micro- kernel
 discussion (i wouldn't want Linus to step in and kick me to hell), but
 if we have the possibility of not having _complex_ interactions within
 the kernel, we are making the kernel itself more resilient to failure.

   Hugo


--XZLT0nNRngx3qG4/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEz0JD7asb/itUNKwRAkAEAJwIM2oieNDDYrJKeZFFweXi0INS7wCfbr1D
exqxAHKqYd1FHNeaRjoOa4s=
=mKZL
-----END PGP SIGNATURE-----

--XZLT0nNRngx3qG4/--
