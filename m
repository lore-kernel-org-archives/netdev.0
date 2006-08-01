From: Hugo Santos <hsantos@av.it.pt>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 1 Aug 2006 12:50:02 +0100
Message-ID: <20060801115002.GX8334@innerghost.net>
References: <20060729133442.GI8334@innerghost.net> <44CC2741.4050706@miyazawa.org> <20060730113050.GL8334@innerghost.net> <20060731.142307.35014994.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="s8wpp40TDz0KNMmP"
Cc: kazunori@miyazawa.org, hadi@cyberus.ca, shemminger@osdl.org,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av.it.pt ([193.136.92.53]:6616 "EHLO av.it.pt")
	by vger.kernel.org with ESMTP id S932671AbWHALuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 07:50:05 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060731.142307.35014994.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--s8wpp40TDz0KNMmP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

David,

> So all of you userland control-plane fanatics, how will you handle
> things like NFS root with these daemon-required variants of NDISC and
> ARP?

   Do it in the initial ramdisk, we only need the daemon to setup the
 NDISC entries to talk to the NFS server. :-)

   There is obviously a cost associated with this, a deployment cost.
 But there are additional factors we must consider. In a later e-mail
 you state that Linux is a generic purpose operating system; how many
 users need to boot from a NFS root (besides myself :-)? I think that we
 must take into consideration that currently Linux is used in lots of
 distinct environments, not only Desktop computers, and servers, but
 also smaller devices. Configuration/Flexibility vs. optimization is
 something that varies a lot depending on the deployment you are talking
 about, and in most of my scenarios, a small mobile device isn't
 required at the moment to push 100Mbps (optimization) but must be
 capable of verifying it's peers and maintaining secure connections
 (flexibility). So, let's be generic?

   I might have some cycles during the month to code up something in
 this direction, at least for an initial review, i'll try to do so.

   Also, the reliability of a system depends on a lot of things, but
 please, let's not use the assumption that because everything sits in
 the kernel, it will be stable as the number of 'points of failure' is
 smaller; this is only true as long as people work to have stable
 components -- and this is independent of where the components sit. A
 few kernel versions ago (2.6.8 if i remember correctly) i couldn't even
 remove a used network interface safely from the system without hanging
 the network stack. It is possible to have stable user-space code, if
 people developing it work to and make sure it is stable.

   Hugo

--s8wpp40TDz0KNMmP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFEzz/q7asb/itUNKwRAkVzAJ9Ry+yhPmxz+mJdjer61ARrnBOTLQCaAs4t
qUXXDbMH82pHNW/TvaNmobA=
=9xlx
-----END PGP SIGNATURE-----

--s8wpp40TDz0KNMmP--
