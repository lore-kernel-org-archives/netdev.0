From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Wed, 19 Aug 2015 11:13:18 +0200
Message-ID: <20150819091318.GV17917@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="8WA4ILJSyYAmUzbY"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>, Ivan Vecera <ivecera@redhat.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:54082 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752205AbbHSJdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 05:33:43 -0400
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8WA4ILJSyYAmUzbY
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 19 02:51, Hayes Wang wrote:
> [...]
> > > The TCs are only reset by a power cycle and there's no known way
> > > to reset them programatically.
>=20
> It could be cleared by setting bit 0, such as rtl_tally_reset() of r8152.

Thanks for this hint.  I'll give it a try.  Is it safe to assume that
this is implemented in all NICs covered by r8169?  Otherwise it's more
safe to use offset values as in my patch, I think.


Thanks,
Corinna

--8WA4ILJSyYAmUzbY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1EiuAAoJEPU2Bp2uRE+g4FEP/jwsosztBxrppZIsqtT5Y0xg
kSltgxEnahou67T2G0QRr9e5cxCPfFBkmtZEwcg3w99a02B/0ISyxr9voB58k4+d
kAvlz0+KGsGaHw/lsfH+VQZE35jeJjode2/PJCzM1mfSCUOzRML6QKvPaY25iHqZ
Bk8mb3VUeDZf7lhlgjz4jjUrPHy2UqLJau1vTD9GmScvLXi2Cx9OCaluAFofIhTu
W5f73a9w5LRL1dv3uLw2eecZTrsx+5txKT/pisVURhf5iWCj1dchqbpafLV15l4H
qj6bIjXpVAC6B4dSInyWtUXw6ns0FNvRkBZRGAg4CVpnArHgDqEJjWX0V7H8tAUe
e7PzG1sqIju5OCXKgT+OiYKp9WiXQcD64grn3euRvp3cvGed9A2NqbTay2LDLLYM
FwqhDhggLdWkBouRUOl0y2a4EaTKg0wnrFD/A5RQd/6YD9eR8mjrwdjKad161smD
SYp//9IS5iWPUWRC+kk1xRZuKGbmVgjg1jdrGcM38+YBJnmqn05g9Qgyf2ETYjIS
H31gsjLYd8CzPIbNpPYw626r3uEz842LXMarGfTas94UgPStSfuytILkqFyUhYbl
YUaauSBvSTjkDV0cmUZXnu5uE1EFqzhELqMmeuWJzjq2sg1Fax/Yw7bUF6FG7S2O
Oz5opoYkP01RL0AaeLSA
=a17x
-----END PGP SIGNATURE-----

--8WA4ILJSyYAmUzbY--
