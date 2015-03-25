From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Wed, 25 Mar 2015 02:39:14 -0700
Message-ID: <1427276354.2601.49.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
	 <87618083B2453E4A8714035B62D6799250274730@FMSMSX105.amr.corp.intel.com>
	 <55113B9B.3090308@cloudius-systems.com>
	 <87618083B2453E4A8714035B62D6799250274C7F@FMSMSX105.amr.corp.intel.com>
	 <5511AFD6.2020406@cloudius-systems.com>
	 <87618083B2453E4A8714035B62D6799250274F2A@FMSMSX105.amr.corp.intel.com>
	 <55127FE6.8030905@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BQQBSIbDf9mdMJmZIT6B"
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"avi@cloudius-systems.com" <avi@cloudius-systems.com>,
	"gleb@cloudius-systems.com" <gleb@cloudius-systems.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:55923 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261AbbCYJjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 05:39:16 -0400
In-Reply-To: <55127FE6.8030905@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BQQBSIbDf9mdMJmZIT6B
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-03-25 at 11:29 +0200, Vlad Zolotarov wrote:
> On 03/25/15 00:50, Tantilov, Emil S wrote:
> >> -----Original Message-----
> >> From: Vlad Zolotarov [mailto:vladz@cloudius-systems.com]
> >> Sent: Tuesday, March 24, 2015 11:41 AM
> >> To: Tantilov, Emil S; netdev@vger.kernel.org
> >> Cc: Kirsher, Jeffrey T; avi@cloudius-systems.com;
> gleb@cloudius-systems.com
> >> Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
> >>
> >>
> >>
> >>> On 03/24/15 20:12, Tantilov, Emil S wrote:
> >>> BTW - there are other issues with your patches. The indirection
> table seems to come out as all 0s and the VF driver reports link
> down/up when querying it.
> >> Worked just fine to me on x540.
> >> What is your setup? How did u check it? Did u remember to patch
> "ip" tool and enable the querying?
> > The issue with the link is that you do not have proper locking when
> calling the mailbox which is messing up the link check subtask.
> Basically you need to protect the calls to ixgbevf_get_rss_key and
> get_reta with the mbx_lock similar to how the driver does it in all
> cases where the mailbox is called.
>=20
> :D Just wrote u the same thing in a reply on your first email...
> Sure. Let me fix it in v8.

Since you will be producing a v8, can you please CC
intel-wired-lan@lists.osuosl.org it is a mailing list we just created
for all Linux kernel patches and kernel development for Intel wired
Ethernet drivers.

We also have a public patchworks project:
http://patchwork.ozlabs.org/project/intel-wired-lan/list/

I had planned on making an announcement on netdev later this week.

--=-BQQBSIbDf9mdMJmZIT6B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVEoJCAAoJEOVv75VaS+3OIYYP/RkPIjGIw3zlzCKkZxmuHTVB
DKrZfEm/sNteYIMOkb6OqlRhYqCZXoSNzna1dXhFRD653RkkEcgPNdxVRnknSnSI
PQX3+kU9cmuhQ/gUB2fRv8FFxaWinGR/4RT8RTfLGi0YL+0uh23O7oB1ZEAFYQV3
F06TQP40NtG4TAuOBoKoIpJ4asK5cbn9gLAeFKAM9aLvCGktinduBlFzr1vkmTxi
4210pwfVgk+HBZOr/R5pURbKUsGHlD8naFLHiLKbFBdJvsk4VMZwAcCCPPMXG1EE
ROG7xtpijYKv5y0TrpL77DG+gZjHiMA6rWl8OI9jLuF8rILaldlhLyZOPgwPQS8T
V0aldlTdei+R3AQIOKNcZbK5bLe3Z9QxhT+MjrpERyJlaUwe2prZ+dvg9XhaTr3d
aMgC3xiASDExSR4p9XMQh0MArN5fD+Rx214naUltLKGCSGs9aIRnzMxsYXKeWg0v
bFm1Mi5YKKgVXDW5vJ4Wb1iN/eTaZzn4tA/gYLH3dFYb3TWSStm0M3ZGgpSvN6kN
HKEOW1Y5uzBywufw6z/sl/3TdJb0VKQUY4RrL/jMbszJvFyi1u1I3Xll1igFNbYq
xY85xTU4P5ZsyROvxBmKDmghGc/FOj72fc9ITrMgbNczWUtlQDbpquhj86du8fO+
R4aA3EbJwvwSMa72LSAX
=IeMz
-----END PGP SIGNATURE-----

--=-BQQBSIbDf9mdMJmZIT6B--
