From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 29 Jan 2017 21:36:11 +0000
Message-ID: <BL2PR07MB23063CA6DC624BDC4ABCCC268D480@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153134.GC2223@localhost.localdomain>
 <BL2PR07MB23065AC5421859AAC6D334348D480@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170129205156.GA30336@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0044.outbound.protection.outlook.com ([104.47.41.44]:55740
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750755AbdA2Vgw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 16:36:52 -0500
In-Reply-To: <20170129205156.GA30336@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > We could - but what difference would it make?
>=20
> It would reduce the chance of missing the next time stamp.

I might have gotten it all wrong, but I was under the assumption that time-
stamped packets are periodic, and that the interval between two isn't
going to be so small.
Is so, how does having a couple of additional instructions in between
jeopardizes the next time stamp?

[Don't take it as an objection - given that we'll send a v3 for this one
we'd make the adjustment here; It's just that I feel like I'm missing
something]
