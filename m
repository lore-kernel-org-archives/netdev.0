From: Martijn van Oosterhout <kleptog@svana.org>
Subject: Re: Modifying Cryptography Code
Date: Tue, 6 Sep 2005 17:24:16 +0200
Message-ID: <20050906152413.GB24388@svana.org>
References: <BAY106-F336464E0C97EA44289AA87ABA70@phx.gbl>
Reply-To: Martijn van Oosterhout <kleptog@svana.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Cc: linux-security-module@mail.wirex.com, linux-crypto@nl.linux.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Alaa Dalghan <alaadalghan@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY106-F336464E0C97EA44289AA87ABA70@phx.gbl>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 06, 2005 at 01:56:56PM +0000, Alaa Dalghan wrote:
> Hello everyone,
> I need to modify some CRYPTOGRAPHY code in Linux Kernel to get a specific=
=20
> VPN behavior, but I don't know where to start.

<snip>

> Each packet sent from a given client to the other get processed 4 times=
=20
> (encryption at the sender, decryption at the gateway, encryption at the=
=20
> gateway, decryption at the receiver). This is the normal behavior but it=
=20
> imposes too much processing overhead on the linux VPN gateway. The requir=
ed=20
> behavior is that the VPN gateway just RELAYS encrypted data (ESP envelope=
s)=20
> without decrypting them. This is impossible in the current ipsec=20
> implementation since"the end of a tunnel HAS ALWAYS to be decrypted".

Umm, if I understand correctly, unless each tunnel is using the same
keys, the decrypt and reencrypt ends up with *different* data. So
just skipping the decrypt won't work, you'll just end up sending
packets which the other end can't read.

If your using the same keys, perhaps the kernal can see that, I don't
know...

Hope this helps,
--=20
Martijn van Oosterhout   <kleptog@svana.org>   http://svana.org/kleptog/
> Patent. n. Genius is 5% inspiration and 95% perspiration. A patent is a
> tool for doing 5% of the work and then sitting around waiting for someone
> else to do the other 95% so you can sue them.

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQFDHbScIB7bNG8LQkwRAiZyAJ0a8nYJXuEhpr3p8HyjixI4dZR7IwCfYFQY
TKYjJfonMK4oIpywRF4uqos=
=xlnA
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--
