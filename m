From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 1/3] ipv6: Select fragment id during UFO/GSO
	segmentation if not set.
Date: Wed, 28 Jan 2015 17:24:51 +0000
Message-ID: <1422465891.2709.38.camel@decadent.org.uk>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
	<1422283026-27832-2-git-send-email-vyasevic@redhat.com>
	<1422326874.31046.239.camel@decadent.org.uk>
	<20150127084208.GB21584@redhat.com>
	<1422366458.13969.11.camel@stressinduktion.org>
	<54C7A007.6050707@redhat.com>
	<1422374551.13969.35.camel@stressinduktion.org>
	<20150127160808.GA10765@redhat.com>
	<1422433508.4678.14.camel@stressinduktion.org>
	<20150128094658.GB16775@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4725650812599665339=="
Cc: netdev@vger.kernel.org, Vladislav Yasevich <vyasevich@gmail.com>,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20150128094658.GB16775@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============4725650812599665339==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-A2MOaqx0qmqzDtYH79zW"


--=-A2MOaqx0qmqzDtYH79zW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-28 at 11:46 +0200, Michael S. Tsirkin wrote:
> On Wed, Jan 28, 2015 at 09:25:08AM +0100, Hannes Frederic Sowa wrote:
[...]
> > I see fragmentation id generation still as security critical:
> > When Eric patched the frag id generator in 04ca6973f7c1a0d ("ip: make I=
P
> > identifiers less predictable") I could patch my kernels and use the
> > patch regardless of the machine being virtualized or not. It was not
> > dependent on the hypervisor.
>=20
> And now it's even easier - just patch the hypervisor, and all VMs
> automatically benefit.
[...]

You are advocating that the hypervisor should continue to act as a
middle-box that quietly modifies packets.  This may be useful to protect
guests that have poor fragment ID generation, but then that should be an
optional netfilter module and *not* the default.  The default should be
that UFO has no effect on the packet headers on the wire, and therefore
that the fragment ID is chosen by the IPv6 stack in the guest.

Ben.

--=20
Ben Hutchings
Teamwork is essential - it allows you to blame someone else.

--=-A2MOaqx0qmqzDtYH79zW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVMkbcue/yOyVhhEJAQozqw/+N+bXKEgToxtD/AyX2VBefyhuvfnxgTKH
LJglXEEuHFg1edeTRiNt0A8lCnAezBYhfAiVE9T1cs5RsU5KqxO31WOn8C7CI1F5
V2HFOt//RuHuQZAG79UEgnF61n19JImVtsu94eqB9/wihPLxhkb+fHHJtJgjUG6K
Add4Bc7Jv+UbAoQrdwIHo6kS7PzsloCiKL5COhZc0XF4qNsOLYR/TkBYqutbESNc
kOH1/IxS0VOWJArqH8n3Bps/2U06J7E/EfgCY96VJXagZOwJAbytcU8NycpdU0El
r4U1eRu/hCQGcRkk1n3nMDq5bGag65qrvh/9COZjz9YRIZ3a2caWHK/W2AaDTBXo
EGRV9APikxwPj8bjp0FnaHYx0P0qOM5vFgCK5u3ib0NgxLpGYXZZ9tqbjY9ooNqK
0sqqBMhK0g0MAlz3Z0aLTmZLqlOLZW9kGjOJpNGjNvgTj0X/J/SdPRTBh5B3rvIz
Lrtyh2Nu7hijSxARHf1E0qNvyXyBuRm+dD/6kxUbvhENq88cqNCeobQiaNVuwQ41
sHfRJ0FLLqUrlD1vDPQ9Hfk6epE7hFGRpDTV6QHc7p31tmKZH7s57TKoe+vRAD8Y
xg5CkwJpWSlyRTi66EXUvskSu0gChR+Br1NTPI7csg7N7G7K/O0rMQz2XP0QHuqS
+kh2AnbLee0=
=sp9b
-----END PGP SIGNATURE-----

--=-A2MOaqx0qmqzDtYH79zW--

--===============4725650812599665339==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============4725650812599665339==--
