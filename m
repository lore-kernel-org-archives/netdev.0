From: Michael Buesch <mbuesch@freenet.de>
Subject: Re: [Bcm43xx-dev] Re: [PATCH] ieee80211_rx_any: filter out packets, call ieee80211_rx or ieee80211_rx_mgt
Date: Sun, 22 Jan 2006 13:25:13 +0100
Message-ID: <200601221325.13553.mbuesch@freenet.de>
References: <20060118200616.GC6583@tuxdriver.com> <200601221359.31482.vda@ilport.com.ua> <200601221408.45486.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1560844.cr1rRdo5s5";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbenc@suse.cz, softmac-dev@sipsolutions.net,
	bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964784AbWAVMZd@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200601221408.45486.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1560844.cr1rRdo5s5
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 22 January 2006 13:08, Denis Vlasenko wrote:
> On Sunday 22 January 2006 13:59, Denis Vlasenko wrote:
> > bcm43xx_rx() contains code to filter out packets from
> > foreign BSSes and decide whether to call ieee80211_rx
> > or ieee80211_rx_mgt. This is not bcm specific.
> >=20
> > Patch adapts that code and adds it to softmac
> > as ieee80211_rx_any() function.
> >=20
> > Diffed against wireless-2.6.git
> >=20
> > Signed-off-by: Denis Vlasenko <vda@ilport.com.ua>
> > --
> > vda
>=20
> Please ignore this one. This is not good:
>=20
> +=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9A=9Areturn ieee80211_rx_mgt(iee=
e, hdr, stats);
>=20
> Use corrected patch in my another email with
> "Date: Sun, 22 Jan 2006 14:04:52 +0200"
> --
> vda

I would say, please also move the
static inline int is_mcast_or_bcast_ether_addr(const u8 *addr)
function into linux/etherdevice.h

=2D-=20
Greetings Michael.

--nextPart1560844.cr1rRdo5s5
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD03mplb09HEdWDKgRAkMNAKCBQgtkK77KENr0QYlHWELdLe5jGQCfVl0e
dQlNBXCXUrVpdbt33BGU8gI=
=PmRV
-----END PGP SIGNATURE-----

--nextPart1560844.cr1rRdo5s5--
