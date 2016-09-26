From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH v2 net-next 2/2] bnx2x: allocate mac filtering pending
 list in PAGE_SIZE increments
Date: Mon, 26 Sep 2016 10:55:03 +0000
Message-ID: <BL2PR07MB23068184A6C078BB9579BD198DCD0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <cover.1474577624.git.jbaron@akamai.com>
 <99fc6a1f17dc200a1de23e1c57d1f6dfb4cfcd96.1474577624.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>
To: Jason Baron <jbaron@akamai.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0071.outbound.protection.outlook.com ([104.47.34.71]:35100
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934759AbcIZLKO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Sep 2016 07:10:14 -0400
In-Reply-To: <99fc6a1f17dc200a1de23e1c57d1f6dfb4cfcd96.1474577624.git.jbaron@akamai.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jason Baron <jbaron@akamai.com>
>=20
> Currently, we can have high order page allocations that specify GFP_ATOMI=
C
> when configuring multicast MAC address filters.
>=20
> For example, we have seen order 2 page allocation failures with
> ~500 multicast addresses configured.
>=20
> Convert the allocation for the pending list to be done in PAGE_SIZE incre=
ments.
>=20
> Signed-off-by: Jason Baron <jbaron@akamai.com>
> Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Cc: Ariel Elior <Ariel.Elior@qlogic.com>

Thanks Jason.
Acked-by: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
