From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed: fix old-style function definition
Date: Thu, 13 Oct 2016 14:15:51 +0000
Message-ID: <BL2PR07MB230694B607619C4DFBB90B7F8DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161010115937.730249-1-arnd@arndb.de>
 <20161013.095532.1238800778112994579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "everest-linux-l2@qlogic.com" <everest-linux-l2@qlogic.com>,
        "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, "arnd@arndb.de" <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0040.outbound.protection.outlook.com ([104.47.32.40]:24352
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933001AbcJMPy3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 11:54:29 -0400
In-Reply-To: <20161013.095532.1238800778112994579.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The definition of qed_get_rdma_ops() is not a prototype unless we add
> > 'void' here, as indicated by this W=3D1 warning:
> >
> > drivers/net/ethernet/qlogic/qed/qed_roce.c: In function =A1qed_get_rdma=
_ops=A2:
> > drivers/net/ethernet/qlogic/qed/qed_roce.c:2950:28: error: old-style
> > function definition [-Werror=3Dold-style-definition]
> >
> > Fixes: abd49676c707 ("qed: Add RoCE ll2 & GSI support")
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>=20
> Again, Qlogic folks, please properly review patches posted against your d=
river.
>=20
> Thanks.

Sorry, managed to miss this one.
Acked-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
