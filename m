From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: bridge is not forwaring ICMP6 neighbor solicitation to
	KVM guest
Date: Tue, 4 Mar 2014 11:52:54 +0100
Message-ID: <20140304105253.GC5090@Linus-Debian>
References: <1566805413.12693479.1393872931017.JavaMail.zimbra@redhat.com>
	<2107636851.12713862.1393876035292.JavaMail.zimbra@redhat.com>
	<20140303212759.GW5090@Linus-Debian>
	<1808019554.12748658.1393886749190.JavaMail.zimbra@redhat.com>
	<20140304000041.GY5090@Linus-Debian>
	<624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r7tUYVWcdYzDJoZW"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org
To: Jan Stancek <jstancek@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <624414844.12834668.1393920156458.JavaMail.zimbra@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--r7tUYVWcdYzDJoZW
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Jan,

On Tue, Mar 04, 2014 at 03:02:36AM -0500, Jan Stancek wrote:
> > For the broken query, ok, it's your manually crafted query. But
> > did you see a query with such a bogus source address "in the
> > wild", too? (I'm curious how urgent this sanity check is)
>=20
> It's real packet I managed to capture during one such occurrence.
> I'm sending it with small C program over raw socket, but it's byte
> by byte exact copy of what I captured with tcpdump previously.
>=20
> I'm not sure how that packet came to existence. Based on IPv6 address
> it came from host B, but all host B was doing at the time
> was running RHEL6 with couple qemu-kvm instances. KVM guests were
> set up to use bridge, so I'm assuming if any of them crafted
> this packet, source IPv6 address would be different.
>=20

Ah, okay. Can you check whether it maybe came from the querier
code in the Linux bridge on host B? Is
"cat /sys/class/net/br0/bridge/multicast_querier" 1? Can you
isolate host B and disable any multicast router daemon on it? Then
check again, if you still see these queries. What kernel version
is running on host B?

Cheers, Linus

--r7tUYVWcdYzDJoZW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFbCFAAoJELxyPiAAt6Uv4TAP/0AnI6uTtEOMLabSy11P7qFT
Pge2dJTPDKju5qCfrEQqDDeOk5c/wDjWS6xgA59yKYV+KFAMCsFEx/UUsP+LFavT
6oRy250c8F1QguPZ8jPD1prW7D4iONb+gndkiYuX/pr68VmRrFGA+lXXFc+2sUXJ
UGO+EIE7njyg6XE3eY6KsYXXPmJlIEmvopIh8lC8k/BjWiqc7a2ma6OtwEus4JEL
ZAOBR5iTIfo96Jo5MgRiTtwwN/dAaBcuEdv8y3GXa5GY8k++DLCffulZ1ldeMUA9
4e0iI5ScqHoMT3ZccoJHYvgsdcpK1Zt+9DDspu4BM9oCptpePsFi9i0t/WDcTdDB
V89DndrDqkfxxENg8ijAOYYliHBzbfmX99jI8c0Vd/rMDWJsZQ581+L3ZpNITotc
8ATTeMOVkKgR7WrEcniZNaoqAOdwDj3rc9/C0G1WAh2lMydcszF/WouVrUcJRd7f
AoRQkmQIEjjxJb9JaaFAKus4YAjOoPWu3XeeDV+SjboJi/u54Ww0BraUcXUv5gWl
VmID4FFdoApntIc5S0Z++AIuL0CasAS9kMamLsmWO7vTfTbntqoJofjRTy//Bgo1
WwrwRoc7bvvGiXxSQh5HxC504drIOQ51O2AdGk9rD5e/1y2DS0ET1Fjo+c/y+wX3
AJxb0/C6FZ5wdqimCnUH
=TZvM
-----END PGP SIGNATURE-----

--r7tUYVWcdYzDJoZW--
