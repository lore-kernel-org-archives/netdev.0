From: Bryan Kadzban <bryan@kadzban.is-a-geek.net>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Mon, 12 Oct 2009 09:19:17 -0700
Message-ID: <4AD35705.2000802@kadzban.is-a-geek.net>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <20091010124731.GA17218@mock.linuxdev.us.dell.com> <20091010162518.GA30354@kroah.com> <4AD0C598.4070403@kadzban.is-a-geek.net> <20091010211352.GC1927@kroah.com> <4AD2CAD8.2040903@kadzban.is-a-geek.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
 protocol="application/pgp-signature";
 boundary="------------enig6E60BCD49BB13F93CE280D72"
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Greg KH <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <4AD2CAD8.2040903@kadzban.is-a-geek.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6E60BCD49BB13F93CE280D72
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Bryan Kadzban wrote:
> (Now, if open() would return effectively a netlink socket bound to
> that ifindex already, such that the program didn't need to fill in
> the various ifindex fields for e.g. rtnetlink... but it's probably
> really hard to do that, so this isn't a serious suggestion.)

Wait, scratch that.  It's not "really hard", it's "almost impossible".

At open() time, you have no idea which netlink family the program wants
to communicate with.  bind() is also hard.  (In theory, you could
support bind() on this new FD -- but then why is userspace using a file
in the first place, and not a socket?)

So this is even less of a serious suggestion now.

I'd still like to be able to refer to NICs by multiple names though, if
we can find a way that works...


--------------enig6E60BCD49BB13F93CE280D72
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEAREDAAYFAkrTVwsACgkQYasYN+YI5W5UaQCgimcd0eFcMYcKXKkfPrgTEKkQ
c0MAnAhfdgkb2Dqe0+aiJxXZUlekcrP8
=JC8d
-----END PGP SIGNATURE-----

--------------enig6E60BCD49BB13F93CE280D72--
