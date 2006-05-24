From: Phil Dibowitz <phil@ipom.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 11:56:45 -0700
Message-ID: <20060524185644.GF22881@ipom.com>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="t4apE7yKrX2dGgJC"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-24-24-245-191.socal.res.rr.com ([24.24.245.191]:12598 "EHLO
	alt") by vger.kernel.org with ESMTP id S932229AbWEXS4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 14:56:47 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4474A489.4080308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--t4apE7yKrX2dGgJC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 24, 2006 at 02:23:05PM -0400, Jeff Garzik wrote:
> I disagree that we should bother about clearing statistics.  It always=20
> adds more complication than necessary.  Few (if any) other statistics in=
=20
> Linux permit easy clearing, often because adding operations other than=20
> 'increment' or 'read' requires adding expensive spinlocks or atomic=20
> operations.

Every networking device in the world supports clearing interface statistics.
Why should linux not be able to do the most basic operation on any
cisco/juniper/enterasys/whatever managed switch or router?

It's a common operation on a network interface, I don't see why this is a
concern.

When I'm debugging a networking issue On a cluster of hundreds and hundreds
of machines at work, I want to be able to reset them all quickly, and get a
rough idea of if they're all climbing, if they're all climbing at the same
rate, etc. And being able to do "for i in `cat hostlist`; do ssh $i ethtool=
 -z
eth0; done" is really, really, REALLY, useful.

As for SNMP statistics, again, this is just like clearing stats on any other
platform - it's a manual thing... you're *choosing* to reset the stats, and
accept the consequences. Its not like the patch introduces some nightly
resetting - it's just an _option_ to users

It's about providing an option that requires no extra complications in the
code (at least in this case), and that has been requested on every
sysadmin-related list I'm on, and in most cases is a re-occuring topic.

--=20
Phil Dibowitz                             phil@ipom.com
Freeware and Technical Pages              Insanity Palace of Metallica
http://www.phildev.net/                   http://www.ipom.com/

"They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety."
 - Benjamin Franklin, 1759


--t4apE7yKrX2dGgJC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEdKxsN5XoxaHnMrsRAhB3AJ9pKfRpqts70UHISxNPwpxWrRR9oQCaA8o/
SYly5uENF1JlBZHbN7mIQO4=
=mjkw
-----END PGP SIGNATURE-----

--t4apE7yKrX2dGgJC--
