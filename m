From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC v2 1/1] net: Add support to configure SR-IOV VF minimum
 and maximum Tx rate through ip tool.
Date: Fri, 28 Mar 2014 00:26:05 +0000
Message-ID: <1395966365.2898.18.camel@deadeye.wl.decadent.org.uk>
References: <1395637073-29794-1-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1395637073-29794-2-git-send-email-sucheta.chakraborty@qlogic.com>
	 <1395687300.2832.37.camel@deadeye.wl.decadent.org.uk>
	 <2029402.2DirnyqmAY@alaris>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JjzlGeLpsVVcwLV2cQ98"
Cc: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com,
	gregory.v.rose@intel.com, linux-net-drivers@solarflare.com,
	Ariel.Elior@qlogic.com, amirv@mellanox.com
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55387 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756172AbaC1A02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 20:26:28 -0400
In-Reply-To: <2029402.2DirnyqmAY@alaris>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-JjzlGeLpsVVcwLV2cQ98
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-03-26 at 08:37 +0100, Michal Kubecek wrote:
> On Monday 24 of March 2014 18:55:00 Ben Hutchings wrote:
> >=20
> > Also, this special-casing of -1 isn't documented anywhere.  Is it even
> > necessary?  If userland needs to set just one limit, it can read the
> > existing limits and set both.
>=20
> Wouldn't this open a window for a race if one process wanted to change=
=20
> one limit and another process wanted to change the other at the same=20
> time? Such scenario doesn't sound very realistic but our customers=20
> taught me that things I don't find very realistic tend to be used quite=
=20
> frequently by them.

If there are two processes trying to change the minimum and maximum
bandwidth of a VF at the same time, something has gone wrong already.
This is a problem for userland to solve.

Ben.

> On the other hand, if changing only one limit is going to be common, it=
=20
> might be more appropriate to add IFLA_VF_TX_MIN_RATE instead and always=
=20
> pass the minimum and maximum rate separately (and pass only one if only=
=20
> one is going to be changed).

--=20
Ben Hutchings
73.46% of all statistics are made up.

--=-JjzlGeLpsVVcwLV2cQ98
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUzTBnee/yOyVhhEJAQpVLQ/5AXeUfm3B1orAtqGZ+r6G/xlRjVhcQSX5
5kU627mvaU3HY8wKzG9bbEW8rx4HKNT+lHBXCjSzHAHVRtLqSlRtBkfRXIV9EMWd
wLcvZifOuQ4t1hoz/16+oxBr+vsHLo8huVg4/GPAN/2nne26jvpZjzUKGOo2MdHf
77Z9luntHXZpoJje/Pkd5D8YM4qojQz7zGPatvj/G9Pna79WWDBOKxVuyvCFR1br
3PB1DK6diHxhifALWcIOhWe6LK6PUvCKeR/yVoenmLLZgC3/rEBYgP1q0Bh28tQ2
LdgI698ipQ1D6/GWeqHe33l4dPMAwOuIgnp7FVeWf2ZX9AnPSmlWdtHwuKwloLq2
q9RUxFGLuvtya0Q9U7IyBvUT/QkpCqlLrDUdY7rG5wgJER5ZZ5bV3mdeMTJ8AUNK
6GSxrm/o4IVEP6tV89OAlzJ7nR4Fwk/YVpqfvMH7nvB2cyhyfzzS5OJdgwID+pX8
quDO2eQPVXAx+gut/U5FlXiCPk8mUJ8xUCX0/Vg/XEHENOBEmp1Yt9Y98C/jisHz
7lTqEIwgzOSqYumYaLKcACIcZgISbgsqB1QAZxW00vi7mbjInu5xGYdHXslqYTYy
PFmbB0kqj3TaRZTliuzlPRYrosgJqIvsuN589cCko/0okpclvEpGcItZaewzgLSp
zLyqxhu/Ei0=
=MuVT
-----END PGP SIGNATURE-----

--=-JjzlGeLpsVVcwLV2cQ98--
