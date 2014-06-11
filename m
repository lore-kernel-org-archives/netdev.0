From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 06/13] i40e: implement anti-spoofing for VFs
Date: Wed, 11 Jun 2014 05:13:02 -0700
Message-ID: <1402488782.2306.18.camel@jtkirshe-mobl>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402303758-1429-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <CAJZOPZJGZNhX7yPF6MvCjW+EYi-EGJgW1GhFa5CO=myAgJj-1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1LHZwg2YFwA4nA1gnfTU"
Cc: David Miller <davem@davemloft.net>,
	Mitch Williams <mitch.a.williams@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48685 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753603AbaFKMN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 08:13:26 -0400
In-Reply-To: <CAJZOPZJGZNhX7yPF6MvCjW+EYi-EGJgW1GhFa5CO=myAgJj-1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1LHZwg2YFwA4nA1gnfTU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-06-09 at 22:49 +0300, Or Gerlitz wrote:
> On Mon, Jun 9, 2014 at 11:49 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > From: Mitch Williams <mitch.a.williams@intel.com>
> >
> > Our hardware supports VF antispoofing for both MAC addresses and VLANs.
> > Enable this feature by default for all VFs
>=20
> What do you expect the HW to do when spoof check is enabled (by
> default) but the admin didn't configure a MAC address for the VF
> through the PF? that is the VF is allowed to use what ever MAC they
> want to?
>=20
> > and implement the netdev op to control it from the command line.

Here is the answer I got:
If the VF mac address is set within the VM and it is accepted by the PF,
than any packets with that mac address would be allowed out of the
interface.

If the VF attempts to send a packet with a mac address that has not been
sent to and accepted/configured by the PF than this would get blocked by
the anti-spoof detection.

The VF mac address must be configured by the PF in either case (set in
the host or set in the VM).

--=-1LHZwg2YFwA4nA1gnfTU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTmEfOAAoJEOVv75VaS+3OqQkP/R4CdstFcJqirnszR1Rg24bw
6VE6scuM/ymNwxl7OyLhsPAlFaKITKCsnpyeyDmsR/86yUk7708V4I84WZMzhK3A
bEHRDTJaKPoPyeO2z+y2+BwCWFVFB2zgyuu5ciFIQZBCXxlOaUIGbCkTIMrNw/8Z
y+RjJd+tmtfGDIa6y0SCdBqjo9pJXNDREhJXylolFM1fihzHf5HIz08xNrurI8f5
4GnaNM64/y/vjfpvqQZNYXuw1OC3Ju3t12uwjV99xqz70e+CfMeM5VKbUKbkGcpo
hKhG9aaz+lSWdwZmhU+IRvVU2im7CWu+gs48BHWCyo2s1NrK8NlDYYpbX5TXIYv5
fVFb96o7QU2H2JAMYu0Ubzun5KFKQ9mqRtq7TK/AEAv4aQcGHq1VZQ/Aks1BlS6G
Qp6fcsETpng0unapZmr8FkbSjvbmt+P1Blxrm1a0KiRWXy3whm2ii0D0gCB/WL//
dZ0KUJicOXW1FbPZL/k+mWxuYx8JFjzyiXNT6BsaSM1eypSryiQ0Hahp/Gd0vxwF
w52yhcnJnnfEhLPZc1qOcXc7EzIggBYg4WdmboljhbyDikQGTEjQqF23W3Merkou
Yrf55YLDfWCiUFiu+Wn18uR10uLZHeWWxi2nVqHwwKopz5HSFaR0Beseo1NcrwgG
Zd/YXPB/BdlEZP8hdeay
=pTBT
-----END PGP SIGNATURE-----

--=-1LHZwg2YFwA4nA1gnfTU--
