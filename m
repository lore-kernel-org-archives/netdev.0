From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH RFC 0/2] ethtool: Add actual port speed reporting
Date: Wed, 2 Nov 2016 15:50:25 +0000
Message-ID: <BL2PR07MB23069B0DB17B981AA43775B18DA00@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: Gal Pressman <galp@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>,
        "Vidya Sagar Ravipati" <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0079.outbound.protection.outlook.com ([104.47.42.79]:47200
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752092AbcKBPu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 11:50:27 -0400
In-Reply-To: <1478100914-23610-1-git-send-email-galp@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sending RFC to get feedback for the following ethtool proposal:
>=20
> In some cases such as virtual machines and multi functions (SR-IOV), the =
actual
> bandwidth exposed for each machine is not accurately shown in ethtool.
> Currently ethtool shows only physical port link speed.
> In our case we would like to show the virtual port operational link speed=
 which
> in some cases is less than the physical port speed.
>=20
> This will give users better visibility for the actual speed running on th=
eir device.
>=20
> $ ethtool ens6
> ...
> Speed: 50000Mb/s
> Actual speed: 25000Mb/s

Not saying this is a bad thing, but where exactly is it listed that ethtool=
 has
to show the physical port speed?
E.g., bnx2x shows the logical speed instead, and has been doing that for ye=
ars.
[Perhaps that's a past wrongness, but that's how it goes].

And besides, one can argue that in the SR-IOV scenario the VF has no busine=
ss
knowing the physical port speed.
