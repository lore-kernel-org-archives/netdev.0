From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL] Please Pull Mellanox Shared Code
Date: Tue, 14 Jun 2016 13:16:50 -0400
Message-ID: <e88d3000-f137-181e-4ea2-cd33101dd57c@redhat.com>
References: <20160613120301.GF5408@leon.nu> <20160614063548.GN5408@leon.nu>
 <20160614.030229.1431969399873476358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="f0vkxEIU8jUnPsKJpElnO6n7wHgA7XScj"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160614.030229.1431969399873476358.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--f0vkxEIU8jUnPsKJpElnO6n7wHgA7XScj
Content-Type: multipart/mixed; boundary="bC57oR1sREKlGMDFvoW86r3RBnHDvbrIv"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Message-ID: <e88d3000-f137-181e-4ea2-cd33101dd57c-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [GIT PULL] Please Pull Mellanox Shared Code
References: <20160613120301.GF5408-2ukJVAZIZ/Y@public.gmane.org> <20160614063548.GN5408-2ukJVAZIZ/Y@public.gmane.org>
 <20160614.030229.1431969399873476358.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
In-Reply-To: <20160614.030229.1431969399873476358.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

--bC57oR1sREKlGMDFvoW86r3RBnHDvbrIv
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 6/14/2016 3:02 AM, David Miller wrote:
>=20
> Please, just stop right now.
>=20
> We're not asking for the a huge patch covering the entire pull
> request.
>=20
> We're asking for you to post a patch series, one per commit, and as
> numbered, fresh, new mailing list patch postings.  As if you were
> submitting these changes for the very first time to the list.
>=20
> Please ask a colleague for how to do this properly before you spam the
> list again with more unnecessary and improperly formatted submissions.

Dave,

He's doing what Linus requested from Mellanox.  They were instructed to
identify all of the coming changes in the next release where patches
sent through your tree and patches sent through my tree would have
conflicts.  They were then instructed to make git commits that merged
those changes and have both you and I pull them (please note "pull", not
git am patches) so that we have the exact same commit hashes in our
trees and git will do the right thing when your tree and my tree are
merged in the next merge window.  As it turns out the conflicts are
mainly in this firmware offset definition file.  They just put all of
the needed changes in there in one commit.  I doubt they have individual
patches here.  This was a custom made patch who's sole purpose is to
combine all the otherwise possibly conflicting changes in one place.
I'm sure they could split it out into different commits, but they
wouldn't be full commits, just the portion that applies to this firmware
file.

--
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
	GPG Key ID: 0E572FDD


--bC57oR1sREKlGMDFvoW86r3RBnHDvbrIv--

--f0vkxEIU8jUnPsKJpElnO6n7wHgA7XScj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJXYDwCAAoJELgmozMOVy/d7TEP/AlqcQ5wrR1HfuH4etIazZa/
pPLGzOCxMvgi/YNGI6tLCdRvyAZ17sGCO/arxFyPt6+Pu7/KLQSSWKQ3kwlyGT68
XT7RmpS3eNhc/TGahW+vlPm0gyNZoJ+G+jjMzM97j73XkXc/e8BK1lVlLvx+Xodw
5TrNB8UFNAJTSJRGCwarwOlWvvmSjfkCVeo7bDXg8ry8frOqcSw6SZgQsvAv2QuI
9PghWI9H+I8OtGe5xqZVQjCViTt7O+Zw4Rrm8UbxevZtf3khqIUMl9xLY7IVfES4
rbwbb1c3RrEICzGu1yufyZZwZotSpMdvqVbYBvf6SAhOFB69MRRz3kWkUHNhpLnO
JuOLp2rR3jCYH6rF2IBdK0Wr5bKRWJAdMob9JLw3knW4BsAZ3IMXtn24NaPXB+JK
SN0PhTZiEVFUvS1bMEnOn+2L8ZgUdxy8mEOUUSZQxtGppzA5O2IziRUjsghiE3Am
Hle+glWuwXGIrRjk8qiFe9VoGLwQQ2WZGBErna4OqcR1UN/f5r6/+3Fvv/L5O1N3
Wg5HCXdjBulJ+1SL6ICzdZpFi8iWB8DYhmIOB+zfpULvI+xYokEYLyK6CvfHdJ7z
3doXqg0yRZeLgZGxod7R4mgfFpnR81TV8h5O0aHj8TxfjviieR8wX2qmsn54zQZE
sy88oNawvLmuBfgLuhUO
=GiOj
-----END PGP SIGNATURE-----

--f0vkxEIU8jUnPsKJpElnO6n7wHgA7XScj--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
