From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Sun, 29 Jan 2017 21:40:08 +0000
Message-ID: <BL2PR07MB23062DCD33399E29B0475A028D480@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>
 <BL2PR07MB2306088B2179138BB4557FE58D480@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170129210227.GB30336@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0081.outbound.protection.outlook.com ([104.47.42.81]:16750
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751012AbdA2V4L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 29 Jan 2017 16:56:11 -0500
In-Reply-To: <20170129210227.GB30336@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > That's part of the driver structuring - qed is responsible for
> > accessing HW so it implements api functions for accessing PTP-related
> > configuration, while qede is responsible for the network interface and
> > thus is the one to register the clock and implements its API.
>=20
> But there is only one 'qed', and so the separation is just busy work.
> Or is there another kind of qed that I missed?

One 'qed'? We have 2 distinct models - QED which provides core functionalit=
y
and supports several other modules as well [qedi, qedr and soon qedf], and
QEDE which contain the Ethernet networking logic.
It's true that there's a one-to-one mapping of instances [ each qede device
is connected to a single qed device], but there's a division of logic betwe=
en
the two.=20
