From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
Subject: Re: [PATCH] skbuff: Add new tc classify variable
Date: Tue, 7 Feb 2012 21:16:33 +0100
Message-ID: <20120207201633.GB26533@pandem0nium>
References: <1328639948-25232-1-git-send-email-siwu@hrz.tu-chemnitz.de>
 <20120207.135841.1753473725075272902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="aVD9QWMuhilNxW9f"
Cc: simon.wunderlich@s2003.tu-chemnitz.de, netdev@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cora.hrz.tu-chemnitz.de ([134.109.228.40]:38491 "EHLO
	cora.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756458Ab2BGUQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:16:35 -0500
Content-Disposition: inline
In-Reply-To: <20120207.135841.1753473725075272902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--aVD9QWMuhilNxW9f
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello David,

On Tue, Feb 07, 2012 at 01:58:41PM -0500, David Miller wrote:
> From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>
> Date: Tue,  7 Feb 2012 19:39:08 +0100
>=20
> > The linux traffic control mechanism has different ways to select the
> > correct class of a qdisc. A common way to do this is to use tc filters
> > that are directly attached to a qdisc. Another approach is to use the
> > iptables classify module. The latter one can reduce the amount of work
> > necessary to process a packet when iptables is already involved in the
> > packet classification.
>=20
> Do not bloat up sk_buff any more.  Add this, and the other existing
> tc_* members to the qdisc SKB control block instead.
>=20

Thanks for your feedback!

I guess you mean skb->cb, but this is also used within mac80211 for various=
 things
(quoting include/net/mac80211.h):

 * struct ieee80211_tx_info - skb transmit information
 *
 * This structure is placed in skb->cb for three uses:
 *  (1) mac80211 TX control - mac80211 tells the driver what to do
 *  (2) driver internal use (if applicable)
 *  (3) TX status information - driver tells mac80211 what happened

We could give it a try, but we most probably run into conflicts again.

I've messed up the CCs in my initial mail (and just resent it) - sorry abou=
t that.
Maybe the mac80211 guys have a suggestion as well :)

Cheers,
	Simon

--aVD9QWMuhilNxW9f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk8xhqEACgkQrzg/fFk7axbRoQCgxHGS8m8aSBvHs2Tyllbx/lmu
Z+wAn1g2l77zpxyp4a1Slv0m8jl7cs1K
=MyYW
-----END PGP SIGNATURE-----

--aVD9QWMuhilNxW9f--
