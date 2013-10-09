From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: pull request: batman-adv 2013-10-09
Date: Wed, 9 Oct 2013 21:01:01 +0200
Message-ID: <20131009190101.GL3544@neomailbox.net>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
 <20131009.135652.2086284751199593695.davem@davemloft.net>
 <20131009.145306.1949528592789606941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="3MMMIZFJzhAsRj/+"
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:5480 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748Ab3JITB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:01:26 -0400
Content-Disposition: inline
In-Reply-To: <20131009.145306.1949528592789606941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3MMMIZFJzhAsRj/+
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Oct 09, 2013 at 02:53:06PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 09 Oct 2013 13:56:52 -0400 (EDT)
>=20
> > Pulled, thanks.
>=20
> Please don't send me stuff that doesn't build:
>=20
> net/batman-adv/translation-table.c: In function =E2=80=98batadv_send_roam=
_adv=E2=80=99:
> net/batman-adv/translation-table.c:2210:49: warning: left-hand operand of=
 comma expression has no effect [-Wunused-value]
> net/batman-adv/translation-table.c:2211:21: warning: left-hand operand of=
 comma expression has no effect [-Wunused-value]
> net/batman-adv/translation-table.c:2210:6: warning: statement with no eff=
ect [-Wunused-value]
> net/batman-adv/translation-table.c:2211:29: error: expected =E2=80=98;=E2=
=80=99 before =E2=80=98)=E2=80=99 token
> net/batman-adv/translation-table.c:2211:29: error: expected statement bef=
ore =E2=80=98)=E2=80=99 toke
>=20
> That looks like:
>=20
> 	/* before going on we have to check whether the client has
> 	 * already roamed to us too many times
> 	 */
> 	if (!batadv_tt_check_roam_count(bat_priv, client))
> 		goto out;
>=20
> 		   "Sending ROAMING_ADV to %pM (client %pM)\n",
> 		   orig_node->orig, client);
>=20
> Looks like a merge problem to me.


Oh damn. Sorry David.
I have probably done something wrong during my last rebase on top net-next.


I'll fix, double check and resend the pull request.


Regards,


--=20
Antonio Quartulli

--3MMMIZFJzhAsRj/+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSVaftAAoJEADl0hg6qKeOAbsQAJoliPEL9r6YvMBymWv6ek3/
nxOKwJRG0dZ+HG/f+20cRRosoWiDrdqFhz1THmgLqI6wQhZwp4gGS+c6iWuSxPNT
n8rPMCvSjXXgWFkUNmuUGoBWjApowUQKNpcBP7jFmqGZ5/Nju1TcqLKIrEbrEoqj
Tp7eaVubTboYsJP/ARNTBg+88Y14MSj6RreNZw/LPn4hZ0e9Rv1FiGEbHh3/GNPH
WConfxhdFSWFcNAUAkRhEEDvC+ULBRdXP32xPuJ0cM45qBSsejw8A37FTNvHUWNt
GMOv8kOm/160Djym9cBXNG6X9FxbxUfzS04HzMh3SXnXJiXTlrk9RQJFnVQGdzeb
OouTz71A6DicZ5oRhvPyKc2j+4MEGknaGU8KFNDEKmYABbGfQJYoVeXHEABjmEqK
VMU7nUf7ZgxjG5cJFSJLKmlClutWmVwKkmSbFB4BawCH+pQwNCy6wmLYayJDIs3U
yewFWshyrIImxN63qjJxdl6mf5uQc6AJ1VU3O2JZ4biil1W/JLt0ytexgHkONKr9
oi1EPwlIxD2uzvwgKsWJtMzz3YXX53QrZ2Fdw3QPiHJke1BYaoJWCxbS+PwJJzWO
EiK0ENE1bt3YzA51bdXU7KP53w8cSuxR3iEkIyObeB7M3fBG9TTbjvQKVaGEl6Td
48WDuuKxSsClEM/064Ym
=bmYs
-----END PGP SIGNATURE-----

--3MMMIZFJzhAsRj/+--
