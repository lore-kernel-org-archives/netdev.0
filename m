From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] ixgbe: add counter for times rx pages gets
 allocated, not recycled
Date: Fri, 01 Sep 2017 12:09:53 -0700
Message-ID: <1504292993.3922.25.camel@intel.com>
References: <150426329512.26774.12697329010993174947.stgit@firesoul>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-NNkPMlLmnFl9bc7JTZD3"
Cc: Alexander Duyck <alexander.duyck@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:24486 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751715AbdIATJz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 15:09:55 -0400
In-Reply-To: <150426329512.26774.12697329010993174947.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-NNkPMlLmnFl9bc7JTZD3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-09-01 at 12:54 +0200, Jesper Dangaard Brouer wrote:
> The ixgbe driver have page recycle scheme based around the RX-ring
> queue, where a RX page is shared between two packets. Based on the
> refcnt, the driver can determine if the RX-page is currently only
> used
> by a single packet, if so it can then directly refill/recycle the
> RX-slot by with the opposite "side" of the page.
>=20
> While this is a clever trick, it is hard to determine when this
> recycling is successful and when it fails.  Adding a counter, which
> is
> available via ethtool --statistics as 'alloc_rx_page'.  Which counts
> the number of times the recycle fails and the real page allocator is
> invoked.  When interpreting the stats, do remember that every alloc
> will serve two packets.
>=20
> The counter is collected per rx_ring, but is summed and ethtool
> exported as 'alloc_rx_page'.  It would be relevant to know what
> rx_ring that cannot keep up, but that can be exported later if
> someone experience a need for this.
>=20
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Since Alex has a suggested change for this patch, when you resubmit v2,
can you make sure you CC intel-wired-lan mailing list, so that my
patchwork project picks up this patch?  Thanks in advance Jesper.
--=-NNkPMlLmnFl9bc7JTZD3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmpsIEACgkQ5W/vlVpL
7c6fdg/9GHecvoGUlFccCeKFJisEJ7oJiynZ9NXfUw3T9Mg4YnqRhSBXJJtuYYBX
u+aL/fkrhmNYy8VETpYrMNw48WtAJS8+5DjWG6T3tMCEehSTImsawAW0nNCBSnon
rBI6KpK/nQi34bU5HdWBcsW0leCy0+RVQQo+2AO0/SOHzQYrl5T4mAifZql6/In9
F4hV303jSTb6/ZrJfJ7gOeAkp1vgAepxiYiPI8gahBnPo5xTrf1JO8sqAhMGHP5Y
Qn4u2KZaolakMZPApP7VJJFh8aPmMbLylz0kDjGbzuRl/dRm0NwVXx5jGb9oTUb6
BRIhL22ohOG4cqNhm/ELcW1S783e3hXRm3H9DqVFrV8EhiBCDHMSasN99Q/TevJw
4RBy6/zQBV0XkSiWV/CHH8RBrsDQj4IB9HsoKpNTo2QCpg6l/pYi5kG1z3a3ZYQO
/+3nYokcglkgJ6vheT5GNPQTzun7GE2rB0HTJbf23SVYhKFcZEPTvdD8KKCf9/U9
DndEYFBpEMnR6rJR2w0zgjqdHWmQtDtmteZZgN+dhPKnil8mcPKYhbPjgZeu99V2
fq7HbG+5OqHReQJhc+My+f2MMkOJtvL7q6pjZbITFP/rdLex2r9Pd2JjpUWzrH+O
i03CznC9FA2sbOo8lSMsdf4PeguGzmAZzts6wcvGq19FholO5qU=
=fI5L
-----END PGP SIGNATURE-----

--=-NNkPMlLmnFl9bc7JTZD3--
