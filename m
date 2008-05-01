From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC/RFT 4/4] mac80211: use multi-queue master netdevice
Date: Thu, 01 May 2008 10:54:24 +0200
Message-ID: <1209632064.4008.4.camel@johannes.berg>
References: <20080430124055.091382000@sipsolutions.net>
	 <1209566743.18659.30.camel@johannes.berg>
	 <1209567609.18659.33.camel@johannes.berg>
	 <200805011021.04435.IvDoorn@gmail.com>
	 (sfid-20080501_101631_486144_2F6FD50B)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-p70kLUsdAvFwovQumTel"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200805011021.04435.IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (sfid-20080501_101631_486144_2F6FD50B)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-p70kLUsdAvFwovQumTel
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I've tested the following patch series:
>=20
> mac80211: clean up get_tx_stats callback
> mac80211: remove queue info from ieee80211_tx_status
> mac80211: QoS related cleanups
> mac80211: use rate index in TX control
> GSO: generalize for mac80211
> mac80211: use GSO for fragmentation
> mac80211: use multi-queue master netdevice
>=20
> My rt61 card (4 TX queues) seems to work correctly, it uses
> queue 3 as default queue, and a few packets seem to go
> over queue 1.

Nice, thanks for testing!

johannes

--=-p70kLUsdAvFwovQumTel
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBmFP6Vg1VMiehFYAQL/sg/7BdDLAFxAE/86fzv0Yltk07PHpOm0gZ+v
dUog31acBvdiKaR9+JsdATtKw7uLrdNe7iiKixrjnY1OagU2gb5612HAbTwnhj7Z
LcamglIF2K7ihd5Z//M4Ya9uYt5c09fohU7Uzv5ibPBJKEuxhzi92zbvE4/EBYsf
uYrTh/uFWEqMukLCGEwnoZui6/4un7Cs/KD+yo+coq43nBRK4v+S37mFE50VxQdW
yMb1CCgP1fgBL7D4++EDrBEyhlSOUBQM6cMRmMkaS/Oa5nMMrZlMGSr4jmfkOMzR
uQ8foAW2+gduF4t2B742hOcou5vQ+wTgBgEW76TTxXHc/iSDehs1MwyS+MWBhwVD
Ui6+CCWh4tMDtRQirFqFuMqzTITgI5NOFtVxY04rIOCni0IZAVofGxOqmExoy8KI
9igHIshLS8mS0nqeEQk702aoZQZxZT8JMOgt1oLpVaLqFWXCo4zt2LdmOye/qA7f
6W3EOvi7WvWOm55YM6wnd9K7P1sNYNeD7Y2zpwTMaSX2FdXzRs0Wq/HhiyCwsr+5
rvmaVtP62xxGPq9iSv42M0Q/gcFC3u0bE+i2fYvnkfCsSnYgOep/0xXsQjXK3+aE
BR4ocsdwndjsxiZigmY7d8ks3Yp+8ZbpQFaSlIqMc9cnv/5JVUdU1bCH91TqnOff
Vx9jgfDpS9U=
=GRWp
-----END PGP SIGNATURE-----

--=-p70kLUsdAvFwovQumTel--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
