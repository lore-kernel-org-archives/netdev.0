From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/6] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 06 Sep 2012 01:44:27 -0700
Message-ID: <1346921067.4228.12.camel@jtkirshe-mobl>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1346888106-25638-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120906080938.GE2550@netboy.at.omicron.at>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KKsgUEYNJjEToEaXEQ+E"
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:60923 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753709Ab2IFIok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2012 04:44:40 -0400
In-Reply-To: <20120906080938.GE2550@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KKsgUEYNJjEToEaXEQ+E
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-09-06 at 10:09 +0200, Richard Cochran wrote:
> On Wed, Sep 05, 2012 at 04:35:01PM -0700, Jeff Kirsher wrote:
> > From: Matthew Vick <matthew.vick@intel.com>
> >=20
> > For users without CONFIG_IGB_PTP=3Dy, we should not be compiling any
> PTP
> > code into the driver. Tidy up the wrapping in igb to support this.
>=20
> So, you have ignored everything I wrote about time stamping
> applications.
>=20
> (no)Thanks,
> Richard=20

As I recall, he stated he was going to integrate your suggestions in a
new patch set that would follow this one.

In regards to your previous comments about the earlier patch I submitted
to wrap the code.  It was to fix a bug when the driver and time stamping
support are both modules.

Also, IMHO, while I look at pre-processor tags all day and get used to
matching up #ifdef to #endif's, I still see #endif /* CONFIG_IGB_PTP */
useful.  While it is not currently consistent, I see it more useful to
fix as we go, rather than create a single patch to add a comment for
every #endif.

--=-KKsgUEYNJjEToEaXEQ+E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQSGJrAAoJEOVv75VaS+3OMbYQAKJwqlEuX7ypud+jTK7Qc0HF
SYwOUC9LUk8YpZfBZ1FAwnjr+trgfCTS60SZ2yBZG1Ym4YOK67XPm3b0KhYHU7FY
QQ4ulpk+lro1i6Ia3oS6E7zDb7qfSXj7oq9p1rTYerF04TfAh5LXtZ/5Jk0/Mxsu
4zIQgWlkst1FtYhUIr1iLU07GhpkVTcsC6NSpWiH2EKtHzBiPhtUEvo2GLzcsz8v
H7oCFoXq4/AzAAB9Aff5hULSk5E5HMZhHnJlwPsp+oPdYfmPAP0rzvrxrIMQeOu5
LX/73zVJTbUuCri0GxzpUZg8xCwB4SdwuSrYjNnX6CGopp2o7BbSt3IOKMIKG8CG
xadmgy1FvkBcin1PrweWKsWXOAv2IQneV1G6ZgHgbHyMyZ8cOEjcFFa/3gBu310N
KfK/x4U3EYp4ZzhrfHCME3BnkRyvh0XTq/dInX4aDZfkIRntFfONXyNB1SBvi+oT
VmS80pPlazPAu3lC1oUoDraHiQ3WxuBevESLLExW94zx3ca4giki7+0wRachFuUO
RHnNcov0c2x4FrgVNEWuWjSLE1QA/I62T0WFvosxpyOAOCfMwywnNbwngFiuTCBL
+QeRR9QAQIMXtz4TbCSLjbgbJPQbzXghUQEapyYWpmMZ/Ax6fApIFtLZH5kpAIrg
eMbejA50tyidDNRobdF8
=lrct
-----END PGP SIGNATURE-----

--=-KKsgUEYNJjEToEaXEQ+E--
