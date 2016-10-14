From: "Chopra, Manish" <Manish.Chopra@cavium.com>
Subject: RE: [PATCH v2 net-next 0/7] qed*: driver updates
Date: Fri, 14 Oct 2016 09:54:05 +0000
Message-ID: <SN1PR07MB24472647A83B446CD367EFAA89DF0@SN1PR07MB2447.namprd07.prod.outlook.com>
References: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>
To: Manish Chopra <manish.chopra@qlogic.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0063.outbound.protection.outlook.com ([104.47.33.63]:30240
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751966AbcJNL2N (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 07:28:13 -0400
In-Reply-To: <1476357771-1578-1-git-send-email-manish.chopra@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Manish Chopra [mailto:manish.chopra@qlogic.com]
> Sent: Thursday, October 13, 2016 4:53 PM
> To: davem@davemloft.net
> Cc: netdev@vger.kernel.org; Yuval.Mintz@qlogic.com; Chopra, Manish
> <Manish.Chopra@cavium.com>
> Subject: [PATCH v2 net-next 0/7] qed*: driver updates
>=20
> From: Manish Chopra <manish.chopra@caviumnetworks.com>
>=20
> Hi David,
>=20
> There are several new additions in this series;
> Most are connected to either Tx offloading or Rx classifications
> [either fastpath changes or supporting configuration].
>=20
> In addition, there's a single IOV enhancement.
>=20
> Please consider applying this series to `net-next'.
>=20
> V2:
> Added a fix for the race in ramrod handling
> pointed by Eric Dumazet [patch 7].
>=20

Hi David, The last patch in this series has caused below kbuild failure.

drivers/net/ethernet/qlogic/qed/qed_spq.c: In function 'qed_spq_blocking_cb=
':
drivers/net/ethernet/qlogic/qed/qed_spq.c:62:85: error: call to '__compilet=
ime_assert_60' declared with attribute error: Need native word sized stores=
/loads for atomicity.

I will re-spin the series with kbuild fix and will send out soon.

Thanks,
Manish
