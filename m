From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000e:  MSI interrupt test failed, using legacy
 interrupt
Date: Thu, 26 Apr 2012 17:46:09 -0700
Message-ID: <1335487569.2783.88.camel@jtkirshe-mobl>
References: <1335485150-2765-1-git-send-email-prasanna.panchamukhi@riverbed.com>
	 <4F99E653.4000608@gmail.com> <4F99EB6B.7090000@riverbed.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Pjmbqqao27x29Q81xYCQ"
Cc: bruce.w.allan@intel.com, jeffrey.e.pieper@intel.com,
	bhutchings@solarflare.com, gospo@redhat.com, sassmann@redhat.com,
	jesse.brandeburg@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: prasanna.panchamukhi@riverbed.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13114 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755195Ab2D0AqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 20:46:11 -0400
In-Reply-To: <4F99EB6B.7090000@riverbed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Pjmbqqao27x29Q81xYCQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-04-26 at 17:42 -0700, Prasanna Panchamukhi wrote:
> On 04/26/2012 05:20 PM, Jeff Kirsher wrote:
> > On 04/26/2012 05:05 PM, prasanna.panchamukhi@riverbed.com wrote:
> >> From: Prasanna S. Panchamukhi<ppanchamukhi@riverbed.com>
> >>
> >> Following logs where seen on Systems with multiple NICs&  ports,
> >> while using MSI interrupts as shown below:
> >>
> >> Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0d.0: lan0_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: wan0_1: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: lan0_1: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:32 (none) user.warn kernel: 0000:40:0e.0: wan4_0: MSI int=
errupt
> >> test failed, using legacy interrupt.
> >> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> >> Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0e.0: wan1_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0e.0: lan1_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: wan2_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: lan2_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: wan3_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: lan3_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0e.0: lan4_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: wan5_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >> Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: lan5_0: NIC L=
ink is Up
> >> 1000 Mbps Full Duplex, Flow Control: RX/TX
> >>
> >> This patch changes the IRQ tests to use polling loops starting with a
> >> delay of 1 tick and doubling that if necessary up to a maximum total
> >> delay of approximately 1 second.
> >>
> >> Signed-off-by: Prasanna S. Panchamukhi<ppanchamukhi@riverbed.com>
> >> ---
> >>   drivers/net/ethernet/intel/e1000e/netdev.c |   27 ++++++++++++++++++=
+++++----
> >>   1 files changed, 23 insertions(+), 4 deletions(-)
> > Thanks Prasanna, Dave did accept the previous patch, so does this patch
> > take that into account?
> No, If Dave has already accepted previous patch we can ignore this patch=
=20
> for now.
>=20
> Thanks,
> Prasanna

Yeah, he has accepted the previous patch so I will ignore this patch.

--=-Pjmbqqao27x29Q81xYCQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPmexRAAoJEOVv75VaS+3OANoQAI3dsWfmrIDZNHR46xgCoHJ+
KFjfXj6T8F4AvDynM90/CCZbsfx/YiQrG9Fn4NiDkM6wnIfKdx5+1KncdiAld+94
Nh0K/5NlGd3PzoOLgkC9aavXw6pxMiyQHpkvPBWljoJTIwLSP2Kr4ST36p7zP9pA
dfLRUvkGDivY6V7XEscKNysXgpYjdzUuOhsQ7bx1VG8M5WS0lB/GFjJimBtVdgFG
5HT18/XYVyQje+RxXunRaPt2Dan4kec01rRfq+RnQpaClzcA6ev1y1l3GukB1tpY
AbilC06naLXgGxebkC4nlC9E+FfZy5l8JgQw0lTi1Qvr/eGbYAEmc5m4zRcH9RQp
new2auRcde8ibPhxBepUyYZJJ+RXJ5CwBiVJSgtc/iinudjWPYxt2ckMdLtfCWxY
hEWzh64ytZVN5JiEv3eiyn4gMJZ3Kt3y/I6GswT/9ktq0yPfWmXV2QRya2LaIdlF
zLQoElhbnjWCLNH8DfPd2U4z0VIMnYsflvZfXUCTMbJwaDTiFtKjxO6aYgmnpVEV
f1VJaTlv6OvhC4j5qVJcziMDBoOOoPqJPQtj7fLPZKGf3WOMlbNJ63dwy3ySIvG8
2/HrIrKrhlZRvfFJuCFYiAHqLuxkv/hHYXM0eG1cdMbG5A34JAOgH66GbprC5m3J
Z9qh1Fy1x+D6okmQU5o+
=KCEm
-----END PGP SIGNATURE-----

--=-Pjmbqqao27x29Q81xYCQ--
