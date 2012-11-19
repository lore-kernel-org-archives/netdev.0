From: Sven Eckelmann <sven@narfation.org>
Subject: Re: [B.A.T.M.A.N.] [PATCH 04/10] batman-adv: export compatibility version via debugfs
Date: Mon, 19 Nov 2012 20:29:07 +0100
Message-ID: <5268262.CIrZ93ERtB@bentobox>
References: <1353313451-2930-1-git-send-email-ordex@autistici.org> <1353313451-2930-5-git-send-email-ordex@autistici.org> <1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart6508802.VGmHYGSYs7"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Antonio Quartulli <ordex@autistici.org>,
	netdev@vger.kernel.org, Marek Lindner <lindner_marek@yahoo.de>,
	davem@davemloft.net
To: b.a.t.m.a.n@lists.open-mesh.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40166 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167Ab2KST3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2012 14:29:12 -0500
In-Reply-To: <1353351150.4156.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart6508802.VGmHYGSYs7
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Monday 19 November 2012 18:52:30 Ben Hutchings wrote:
> On Mon, 2012-11-19 at 09:24 +0100, Antonio Quartulli wrote:
> > Different versions of the batman-adv module may use the same compatibility
> > version, but this is not understandable at runtime (the only way is to
> > parse the kernel log and fetch the batman-adv advertisement message on
> > loading). The user may want to know whether two nodes using different
> > versions can communicate or not. For this purpose the module has to
> > export this value through debugfs.
> [...]
> 
> I do hope that you're not planning to use unstable debugfs interfaces
> indefinitely.

Why are you refering to the adding of an file as "incompatible" debugfs 
interface? I would call it additional information. And the rest of the commit 
message is talking about *possible* protocol incompatibilies of the network 
protocol (which caused this uncontrolled erruption of anger in a network 
maintainer).

Kind regards,
	Sven
--nextPart6508802.VGmHYGSYs7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQqoiDAAoJEF2HCgfBJntG9KoP/ijqUPa/sKIKOajMLSMl9Z9i
IRuwe3FLT3CMy1Eei+e6f9nGlYvYaT3YV9j355PnDWneY+CPP09qNWYet2znbnwL
B50/SRYzvV0CAWs3bjczSZXtPvaIe43gEYSkgSdwd3XBWnkkicY/A3J4JxGwtUhL
TvocJK7XpAOyOj0ESFzactfGYZhs4c0WkcHM4pvWoMVdAFAO2PvmUkOzTZCHVoU1
Z0TjKbZzMzJRFJjtfQqdb2nijeaXzzWlQ419KEfYPmfqjLE2skBkSS3rMRB0ha82
7z+CCJbrnFjsAu3MMzpQbIh3/mPgVvBd4hW+x1+QmJ93JIpy8eeP1cHd0Hh/kh4p
2V5t3FWOofPNSqMd9lsKrNaquMbDnIqCOrCychgCdigxY59UPeOTjLAfpU9MUZSt
eFCJCTcJw4cJ/jbKjvVhjcTq3WCcWAkkXS3vNUh6UOmhGwssFQKEpAGN9PTZ+rlo
RCOAVcrDVruIWeuNOhQcGBfAT+aElnVWP13M4IYojA1fiqJkSOlR9w6bKxkm5UXc
AwuGc8iljhXexsHQ4EZClKN1Y3+Rj3u/OjqIcq2NvGibAy0CR6YQIj6qOdLQKLuz
O5AkEX2mIkaaaC+uQOHV6zBvU0sbl4Tx+DrHFfpAtcGiD5GeA995TMSqzJgbzV97
gsUve5iX+1+l0GVCQhiz
=BNJk
-----END PGP SIGNATURE-----

--nextPart6508802.VGmHYGSYs7--
