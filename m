From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 16/19] ibmveth: Automatically enable larger rx buffer
 pools for larger mtu
Date: Fri, 13 Jun 2008 15:18:34 +1000
Message-ID: <20080613151834.8dbcaa14.sfr@canb.auug.org.au>
References: <20080612215312.GF30916@linux.vnet.ibm.com>
	<20080612222249.GX30916@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__13_Jun_2008_15_18_34_+1000_A_i89JqwjiWM73Rm"
Cc: paulus@samba.org, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	David Darrington <ddarring@linux.vnet.ibm.com>,
	Brian King <brking@linux.vnet.ibm.com>
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:42994 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752790AbYFMFSk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 01:18:40 -0400
In-Reply-To: <20080612222249.GX30916@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__13_Jun_2008_15_18_34_+1000_A_i89JqwjiWM73Rm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Robert,

On Thu, 12 Jun 2008 17:22:49 -0500 Robert Jennings <rcj@linux.vnet.ibm.com>=
 wrote:
>
> +	/* Deactivate all the buffer pools so that the next loop can activate
> +	   only the buffer pools necessary to hold the new MTU */
> +	for(i =3D 0; i<IbmVethNumBufferPools; i++)

Please uses spaces after "for" and around binary operators.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__13_Jun_2008_15_18_34_+1000_A_i89JqwjiWM73Rm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkhSAyoACgkQTgG2atn1QN+IFACeLp6arVU4HXSJZe9bgGn13EWD
j6cAnAnzXuR2RJet2xbzhTuj7kJebEWj
=nN5n
-----END PGP SIGNATURE-----

--Signature=_Fri__13_Jun_2008_15_18_34_+1000_A_i89JqwjiWM73Rm--
