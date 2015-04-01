From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next v10 3/7] ixgbe: Add a RETA
 query command to VF-PF channel API
Date: Wed, 01 Apr 2015 00:33:48 -0700
Message-ID: <1427873628.2662.8.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-4-git-send-email-vladz@cloudius-systems.com>
	 <1427787327.2497.111.camel@jtkirshe-mobl>
	 <87618083B2453E4A8714035B62D67992502896D2@FMSMSX105.amr.corp.intel.com>
	 <551B9E69.7090700@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-hsSJFtBoWbMdqmPfeQRQ"
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:20377 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbbDAHdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 03:33:49 -0400
In-Reply-To: <551B9E69.7090700@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-hsSJFtBoWbMdqmPfeQRQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-01 at 10:29 +0300, Vlad Zolotarov wrote:
> On 04/01/15 02:55, Tantilov, Emil S wrote:
> >> -----Original Message-----
> >> From: Intel-wired-lan
> [mailto:intel-wired-lan-bounces@lists.osuosl.org] On Behalf Of Jeff
> Kirsher
> >> Sent: Tuesday, March 31, 2015 12:35 AM
> >> Subject: Re: [Intel-wired-lan] [PATCH net-next v10 3/7] ixgbe: Add
> a RETA query command to VF-PF channel API
> >>
> >> On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> >>> Add this new command for 82599 and x540 devices only. Support for
> >>> other devices
> >>> will be added later.
> >>>
> >>> 82599 and x540 VFs and PF share the same RSS redirection table
> (RETA).
> >>> Therefore we just return it for all VFs.
> >>>
> >>> For 82599 and x540 RETA table is an array of 32 registers (128
> bytes)
> >>> and the maximum number of registers that may be delivered in a
> single VF-PF channel command is
> >>> 15. Therefore we will deliver the whole table in 3 steps: 12, 12
> and 8 registers in
> >>> each step correspondingly.
> > The above paragraph no longer applies to this patch. Perhaps Jeff
> can strip it to avoid having to resend the
> > patch just for the description.
>=20
> Right. Thanks, Emil.
> The "compression" implemented in v9 voids the issue above and indeed
> the=20
> last paragraph above should be stripped.
> Jeff, let me know if u want me to respin the series with the fixed=20
> description in this patch.

Just respin this single patch, not the entire series, please.

--=-hsSJFtBoWbMdqmPfeQRQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVG59cAAoJEOVv75VaS+3OyBsP/1QlX0EvdIgh/y2PIqt4Rr3I
EWTJ9x2FvH6ub//zJ7yCGwhMxQSFKkVHSiFO/upyNIctTpHe6D/a27ZLbxGnJktz
8KwzCG2ZzBkm7J7bnai6xC9KWwcEyvcbmY3GSxZbCrRgFcWgKO+cLAaD8Nk2wU3Y
/7SbhyRZlm7RbDm4voAEKSXsK6Ne10YXy0+P50stNToKPXDxDaEngPhNNiaFv7vJ
eaNI+A6klZRt38pLYPMYWU+Nb3R8rcHwhMy6zNDuKCOQRFPYSU+3jztKc0dyEUJH
qc/cm4fUpjZPjln4TbxmCp8zQ3PW0CudX9l6+Y3UqhIHx81mhwqQlfvvmYw/yvqM
Tr9Y44Uy2syp8tipdj8ohnHcNn5symu7dJ/65GwVaeNyc9ntWfzNmHguhE6JMFDj
d7HhwxGp+r27wtjVlWJAHb2dV3X5UXDft/+kunLz5Yl/bgEyZoNvexuIJvlE1uAV
Rf9wZKHtbcBydT1AgH+vK98rSGX6hqlNoXJEr8H0ZE3uX+Kuf+KJi+hw5eUGdGar
JjD+n24N+RZrS5R9TKemheQVrUk+j9dm2dJ6ZTmIUnSM60E2Zggg1naOmnstINWp
Ff4tezoUXjJ1lsbGiqFc/VUMENkb/zpXS0kUU2XsRAQCRjEJJ+8OZPd1hXYU/ByE
rFs1H+VvKzXFmQSL7d4c
=4uw5
-----END PGP SIGNATURE-----

--=-hsSJFtBoWbMdqmPfeQRQ--
