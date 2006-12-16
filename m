From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver
Date: Fri, 15 Dec 2006 21:52:20 -0500
Message-ID: <200612152152.25419.flamingice@sourmilk.net>
References: <20061215225123.GA3231@dmt>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3008910.8lt3XrTrXD";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
	Dan Williams <dcbw@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"John W. Linville" <linville@redhat.com>, dyoung@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:52140 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965318AbWLPDZa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 22:25:30 -0500
To: Marcelo Tosatti <marcelo@kvack.org>
In-Reply-To: <20061215225123.GA3231@dmt>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3008910.8lt3XrTrXD
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 15 December 2006 17:51, Marcelo Tosatti wrote:
>--- a/include/net/ieee80211_radiotap.h
>+++ b/include/net/ieee80211_radiotap.h
>@@ -168,6 +168,23 @@ struct ieee80211_radiotap_header {
>  *      Unitless indication of the Rx/Tx antenna for this packet.
>  *      The first antenna is antenna 0.
>  *
>+ * IEEE80211_RADIOTAP_RX_FLAGS          u_int16_t       bitmap
>+ *
>+ *     Properties of received frames. See flags defined below.
>+ *
>+ * IEEE80211_RADIOTAP_TX_FLAGS          u_int16_t       bitmap
>+ *
>+ *     Properties of transmitted frames. See flags defined below.
>+ *
>+ * IEEE80211_RADIOTAP_RTS_RETRIES       u_int8_t        data
>+ *
>+ *     Number of rts retries a transmitted frame used.
>+ *
>+ * IEEE80211_RADIOTAP_DATA_RETRIES      u_int8_t        data
>+ *
>+ *     Number of unicast retries a transmitted frame used.
>+ *
>+ *
>  * IEEE80211_RADIOTAP_FCS              u32       data
>  *
>  *     FCS from frame in network byte order.
>@@ -187,7 +204,11 @@ enum ieee80211_radiotap_type {
>        IEEE80211_RADIOTAP_ANTENNA =3D 11,
>        IEEE80211_RADIOTAP_DB_ANTSIGNAL =3D 12,
>        IEEE80211_RADIOTAP_DB_ANTNOISE =3D 13,
>-       IEEE80211_RADIOTAP_EXT =3D 31,
>+       IEEE80211_RADIOTAP_RX_FLAGS =3D 14,
>+       IEEE80211_RADIOTAP_TX_FLAGS =3D 15,
>+       IEEE80211_RADIOTAP_RTS_RETRIES =3D 16,
>+       IEEE80211_RADIOTAP_DATA_RETRIES =3D 17,
>+       IEEE80211_RADIOTAP_EXT =3D 31
> };
>
> /* Channel flags. */
Did you send this part to netbsd also? We really don't want to fork=20
radiotap. ;) Also, this should be in a separate patch, but I'm guessing it'=
s=20
all rolled together for convenience.

=2DMichael Wu

--nextPart3008910.8lt3XrTrXD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFg19pT3Oqt9AH4aERAnT1AKDGZIDIYb7QaK8qQs04Pd8jRHzoMACfY44x
4A0Ibf/gzuzgO38BZ0034Es=
=ko7a
-----END PGP SIGNATURE-----

--nextPart3008910.8lt3XrTrXD--
