From: "Fruhwirth Clemens" <clemens-dated-1022873908.6a98@endorphin.org>
Subject: extending dst_entry
Date: Sun, 26 May 2002 21:38:28 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020526193828.GA3366@ghanima.endorphin.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

hi!

i'd like to add an netfilter module, which limits the diversity of tcp/udp
ports for a given remote peer via a tocken bucket filter. the aim of that is
mainly an instant response to port scans. it's quite easy to modify the
"limit" module that netfilter has right now, but in opposite to this module
my module will need to store information with every remote peer instead of a
global match rule state.
so i'm thinking about extending dst_entry and further dst.c to contain
netfilter specific code, which lead to a not so nice spagetti code
architecture.

any other suggestions how i could store peer specific information without
implementing an dst_entry styled hashtable on my own?

clemens

please CC me, not on list.

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE88Tm0HkYGUbdPrgQRApw0AJ9wpEGby4CH+CvFAumeRQgMpJO95QCfWFrF
W1vmy6/1jlBftfAM3yIjY2o=
=voQX
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
