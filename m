From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH V1 net-next] IB/ipoib: Fix ndo_get_iflink
Date: Mon, 20 Apr 2015 11:37:02 -0400
Message-ID: <1429544222.45956.1.camel@redhat.com>
References: <1429191274-11600-1-git-send-email-erezsh@mellanox.com>
	 <20150417.152133.1818018053733533978.davem@davemloft.net>
	 <5534B5E2.6060804@mellanox.com>
	 <CAJ3xEMgRDT+h7D3smju2VFTovA4J38ZnK3R4PD4+Xisbg40Tyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-XbQ1agsRyWNqGDw20AZt"
Cc: Haggai Eran <haggaie@mellanox.com>,
	Roland Dreier <roland@kernel.org>,
	David Miller <davem@davemloft.net>,
	Erez Shitrit <erezsh@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Honggang Li <honli@redhat.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45161 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751443AbbDTPhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2015 11:37:07 -0400
In-Reply-To: <CAJ3xEMgRDT+h7D3smju2VFTovA4J38ZnK3R4PD4+Xisbg40Tyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XbQ1agsRyWNqGDw20AZt
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-04-20 at 12:21 +0300, Or Gerlitz wrote:
> On Mon, Apr 20, 2015 at 11:16 AM, Haggai Eran <haggaie@mellanox.com> wrot=
e:
> > On 17/04/2015 22:21, David Miller wrote:
> >> From: Erez Shitrit <erezsh@mellanox.com>
> >> Date: Thu, 16 Apr 2015 16:34:34 +0300
> >>
> >>> Currently, iflink of the parent interface was always accessed, even
> >>> when interface didn't have a parent and hence we crashed there.
> >>>
> >>> Handle the interface types properly: for a child interface, return
> >>> the ifindex of the parent, for parent interface, return its ifindex.
> >>>
> >>> For child devices, make sure to set the parent pointer prior to
> >>> invoking register_netdevice(), this allows the new ndo to be called
> >>> by the stack immediately after the child device is registered.
> >>>
> >>> Fixes: 5aa7add8f14b ('infiniband/ipoib: implement ndo_get_iflink')
> >>> Reported-by: Honggang Li <honli@redhat.com>
> >>> Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
> >>> Signed-off-by: Honggang Li <honli@redhat.com>
> >>
> >> Applied, thanks.
> >
> > Doug, Roland,
> > You might want to include this patch in your for-next / for-4.1 trees,
> > or merge net-next again. Currently they contain the issue it fixes, and
> > it can prevent some systems with IPoIB from booting.
>=20
> Haggai,
>=20
>=20
> It's upstream by now, pull Linus tree.
>=20
> Or.

Right, it already went via net-next.  I skipped it because of that.

--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--=-XbQ1agsRyWNqGDw20AZt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJVNR0eAAoJELgmozMOVy/dLFAP/2hlp3nJlAlWKqnqIzM+2X5R
QJCSstcSLijV6eAotCqvjvaxXq86HGQG9j8E9o7QYl1EFSzuhc3i04uPAnGyyt+A
7eM7vfkCKZTxwvdnclnpSJvBA+JEtz5ADOXvIHvX14zdZ4uuygGmBRGXn/PACo3Z
1xTwcmV1tlMbqhXyYY0EHqCMjP9MAxit67k9yiEaQuBLi5MK29bh91xeLjxoFAvx
ucmHtadSG6H3tP8KE/skrsVPEUkoGb/aObvn2xMTSL1aqGTJfo7EgxFM6ZvKpC2U
ym5yZnxMroy9AIv8PagHUdiMdcXGNFG/+bZLJAJB+VESUJnUBYBDbyz/sS3fwGE9
qVK9BoiXtu3rAM4iIOJUkGOZ+VkYMPeTFMWT0+63DbRiBKvXA66SjYlUBWEqFJVF
hfG9D5+NLxUtSdCOGFWvLw7NXq3tN9oSlz9Re4RxUGRKyYVNzPbkuNxPfwvL4rHq
GuVdDhBUTfM8CUU9DCngNC2+CXUnUlu/a63g+bru7Qodx2y2/jzeAXN0O9U6KV3Q
0fIq6Y0LgQPBLfejZM57wtpRXMCDVMWledROjorK9W7n7m4GRhl534WsYUGayEEY
yUlf2aFnkxgBuuf5eIP6d3RrQuU/is3kahtMUCjhRP7PwvDh0M02KMeVnIR5xxjs
BHMrCvja8Dy0kHB/e0Ys
=8tVZ
-----END PGP SIGNATURE-----

--=-XbQ1agsRyWNqGDw20AZt--
