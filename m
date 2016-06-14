From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [GIT PULL] Please Pull Mellanox Shared Code
Date: Tue, 14 Jun 2016 20:51:33 +0300
Message-ID: <20160614175133.GQ5408@leon.nu>
References: <20160613120301.GF5408@leon.nu>
 <20160614063548.GN5408@leon.nu>
 <20160614.030229.1431969399873476358.davem@davemloft.net>
 <e88d3000-f137-181e-4ea2-cd33101dd57c@redhat.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="sBcizk6cgRZY6rnJ"
Cc: David Miller <davem@davemloft.net>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, matanb@mellanox.com, saeedm@mellanox.com
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:38896 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbcFNRvj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 13:51:39 -0400
Content-Disposition: inline
In-Reply-To: <e88d3000-f137-181e-4ea2-cd33101dd57c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sBcizk6cgRZY6rnJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 14, 2016 at 01:16:50PM -0400, Doug Ledford wrote:
> On 6/14/2016 3:02 AM, David Miller wrote:
> >=20
> > Please, just stop right now.
> >=20
> > We're not asking for the a huge patch covering the entire pull
> > request.
> >=20
> > We're asking for you to post a patch series, one per commit, and as
> > numbered, fresh, new mailing list patch postings.  As if you were
> > submitting these changes for the very first time to the list.
> >=20
> > Please ask a colleague for how to do this properly before you spam the
> > list again with more unnecessary and improperly formatted submissions.
>=20
> Dave,
>=20
> He's doing what Linus requested from Mellanox.  They were instructed to
> identify all of the coming changes in the next release where patches
> sent through your tree and patches sent through my tree would have
> conflicts.  They were then instructed to make git commits that merged
> those changes and have both you and I pull them (please note "pull", not
> git am patches) so that we have the exact same commit hashes in our
> trees and git will do the right thing when your tree and my tree are
> merged in the next merge window.  As it turns out the conflicts are
> mainly in this firmware offset definition file.  They just put all of
> the needed changes in there in one commit.  I doubt they have individual
> patches here.  This was a custom made patch who's sole purpose is to
> combine all the otherwise possibly conflicting changes in one place.
> I'm sure they could split it out into different commits, but they
> wouldn't be full commits, just the portion that applies to this firmware
> file.

Thanks Doug,

In addition to your accurate description. We don't have separate commits
for this file (mlx5_ifc.h) for many reasons: auto generated file, one
logical change (enable FW features), no helpful for bisect e.t.c.

My goal was to simplify the maintainers' work by sending minimal
possible pull request with easy for review information.

I also resent the pull request [1] as a cover letter together with patch it=
self [2].

[1] http://lkml.kernel.org/r/1465900500-1578-1-git-send-email-leonro+()+mel=
lanox+!+com
[2] http://lkml.kernel.org/r/1465900500-1578-2-git-send-email-leonro+()+mel=
lanox+!+com

Thanks.

>=20
> --
> Doug Ledford <dledford@redhat.com>
> 	GPG Key ID: 0E572FDD
>=20




--sBcizk6cgRZY6rnJ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXYEQlAAoJEORje4g2clinlFUQAIivuJXDiYTNSPa22grhCJgU
7oeFkn/4FqzZKOi0imnZCyrhmyt6Tgbw9EOw1LzAe0tqfR6kylbrLgFyjGr25ktf
mGj2fNsGZV1DhyK8iIJMhzyD/HXuykRhhEOXdgoSykygTYOlzU7cv+iOwl9LXNs4
r/BdHkJhxkGriBYgUMG4rr+iun1JgMti2/IAGG5QvFKB/bVGw9VPDV3Qvabp3L55
mNSRuMehg99D7S97qR5Am2qlTwyr2zcfxTLWzUOVGNSTzfZaDEHaCif6QrDpW0mH
S9rO61ny37764IeO3fBALoIrVYAKHazVn1uJUIQK/xHCDnLdZRUqfJnlUJDp8b0G
jye6IyI/JtF5gZuWTk5oR2b88U+GQPqciw2dtOVmQDCKBIW4tmfIe7+lCuYP+saJ
C2wSZUYNYLdI96Dvz40ovu3bnKibedgFB04R/ZfPo3bwRTZSySQY74NbcxhCk0Jm
Ze4jc//HUIYpEmKd3pR3HKOpbUvlrQGu6umZN/bvNr8ZLfBhM5qEOuXo1fEUDvXH
z1hdsm810tDHGTobSxNJUflBNyMVbQ2Pa4KTIOtPh58MP7+cNvsylZQT8ZqGSnJX
Np8H+HNTfdaVsKEtE688HHHQehfZ1X+RtlNoqKx1wfC8fR4dDHYL0T/pYWgdYMO6
xj8W517gABMN5ihFawbT
=HBip
-----END PGP SIGNATURE-----

--sBcizk6cgRZY6rnJ--
