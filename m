From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [RESEND 3/5] [NET]: Protocol Independant Policy Routing Rules
	Framework
Date: Sat, 29 Jul 2006 09:25:21 +0200
Message-ID: <1154157921.23563.46.camel@localhost.localdomain>
References: <20060726221100.325687073@postel.suug.ch>
	 <20060726221849.807482409@postel.suug.ch>
	 <Pine.LNX.4.64.0607270158001.4779@d.namei>
	 <20060726.230230.111423566.davem@davemloft.net>
	 <20060727223931.GZ14627@postel.suug.ch>  <44C94529.5080605@trash.net>
	 <1154078728.23563.21.camel@localhost.localdomain>
	 <44CABC7D.2080903@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-TAg8ycvy9bbaprUzY+rF"
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	jmorris@namei.org, netdev@vger.kernel.org, vnuorval@tcs.hut.fi,
	usagi-core@linux-ipv6.org, yoshfuji@linux-ipv6.org,
	anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront1.citynet.nu ([217.10.96.36]:24299 "EHLO
	mailfront1.citynet.nu") by vger.kernel.org with ESMTP
	id S1422679AbWG2HZ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jul 2006 03:25:58 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44CABC7D.2080903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-TAg8ycvy9bbaprUzY+rF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2006-07-29 at 03:40 +0200, Patrick McHardy wrote:
> Martin Josefsson wrote:
> > As a somewhat related note, I've just digged a bit through RCU land,
> > talked to dipankar and mckenney, and discovered that rcu_read_lock() /
> > rcu_read_unlock() aren't strictly needed in softirqs since preempt is
> > already disabled in softirqs. This means that you can use the result of
> > the rcu read-side critical outside of the rcu_read_lock() /
>=20
> Thats true, but in this case the code is executed both in softirq-
> and user-context. Using rcu_read_lock and still relying on softirq
> properties outside the locked section is also very confusing in my
> opinion.

Yes it is very fishy relying on the softirq properties, especially since
they don't apply to -rt kernels and that there might be other changes in
this area in the future. It's not recommended.

--=20
/Martin

--=-TAg8ycvy9bbaprUzY+rF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQBEyw1hWm2vlfa207ERApO6AJ9W+Y2LmgDZoAnanvmOyQ4KcTwyrgCghuLV
zv3n1/OuRBLudYwWWUaQZoM=
=R/ez
-----END PGP SIGNATURE-----

--=-TAg8ycvy9bbaprUzY+rF--

