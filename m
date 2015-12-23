From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH V1 00/16] add Intel(R) X722 iWARP driver
Date: Wed, 23 Dec 2015 12:24:18 -0500
Message-ID: <567AD8C2.3040007@redhat.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <567AC754.5020508@redhat.com> <20151223163549.GA22244@flatif-MOBL1>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="XKR37grWts4MBFSI4q7nUxmqacEd8k3QB"
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, e1000-rdma@lists.sourceforge.net
To: Faisal Latif <faisal.latif@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964922AbbLWRYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 12:24:20 -0500
In-Reply-To: <20151223163549.GA22244@flatif-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--XKR37grWts4MBFSI4q7nUxmqacEd8k3QB
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/23/2015 11:35 AM, Faisal Latif wrote:
> On Wed, Dec 23, 2015 at 11:09:56AM -0500, Doug Ledford wrote:
>> On 12/21/2015 06:13 PM, Faisal Latif wrote:
>>> This (V1) series contains the addition of the i40iw.ko driver after
>>> incorporating the feedback from Christoph Hellwig and Joe Perches for=

>>> initial series.
>>>
>>> This driver provides iWARP RDMA functionality for the Intel(R) X722 E=
thernet
>>> controller for PCI Physical Functions. It also has support for Virtua=
l
>>> Function driver (i40iwvf.ko), which that will be part of separate pat=
ch
>>> series.
>>>
>>> It cooperates with the Intel(R) X722 base driver (i40e.ko) to allocat=
e
>>> resources and program the controller.
>>>
>>> This series include 1 patch to i40e.ko to provide interface support t=
o
>>> i40iw.ko. The interface provides a driver registration mechanism, res=
ource
>>> allocations, and device reset coordination mechanisms.
>>>
>>> This patch series is based on Doug Ledford's k.o/for-4.5.
>>
>> My apologies Faisal.  I had pushed that branch to github to get 0-day
>> testing, but hadn't committed it to my k.o tree as it wasn't fully
>> finalized (I was waiting for Or to get his chance to respond to it).
>> Once Or responded, I ended up taking his patchset instead, which means=

>> you need to adjust your patches accordingly.
>>
>=20
> Thanks Doug for the update, I will provide new patch series for latest
> k.o. Also will make sure of shallow threading for the series. I should
> have used V2 for this series instead of V1 and next series with k.o wil=
l
> make it proper with V3.

I'm going to repush my tree in 10 or 15 minutes if you haven't done the
rebase yet.  If so, the tree I pushed earlier this morning should be
good enough.


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--XKR37grWts4MBFSI4q7nUxmqacEd8k3QB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWetjDAAoJELgmozMOVy/dCH0QAICIZc8eRniu2i4Cb8dUNDih
zj5F+GM0De/RqlbFsVeNqx7y+fCDZ69ZnE3ASlw9qlq4H9cCgiPPm6jjJReUmuj6
8PD0revrBC//sgbyWHszLhSQuUjo/K+xw6Evz80zOHu0wf2hNrRo2B3TZthcNerq
HMjSM9k2vEvFNUuYYZtH3ItTplAOjB0my6p95FfsAB+C1axRIRoFJMSXtQFplvV1
8in+6gQSTRbNlfXxfWw+/MYP0y6m4XtDFQhq8b+WMAZT+zCN56l4aPAjWjknsfW8
F07aJGoiJG3i49ConoBSDpBzIcFCSOFmP5h8F6QSBCpHB7Ovh8RpDyVqrqWfSL3l
0U4HzuL3C54jxeYSo6gNp0yl0Cyc2Q+uBPt/dZaFQGgU1n+WlSr2JTAbLDlseH+I
3z2rTsledEQVo2v2hzAWJSRZo8QhzByiKgYkSNLNSAP6XL2xAjk2uFX5NOk3DCN0
P8CiowgwTnzN+K15kzIw6U/bfN9+4UYzSJUG3K1CPGgKrPGXs/iTfInZuM6He7Z3
m2iSF4ait2wqIsNr79d98kTGTP7Cn1qp3Upk5lijwWB1W8cMgikRb2YuQM8CqZcr
Jp6FgOLIGf90pyMY3E2/2cFyH8jhTqYZmwd7N8kCIB5suGqB00prgwSul7Pqd3gi
SMFGTTZa6rHtB+IVS+t7
=z/7o
-----END PGP SIGNATURE-----

--XKR37grWts4MBFSI4q7nUxmqacEd8k3QB--
