From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH] qed: Fix to use list_for_each_entry_safe() when delete
 items
Date: Thu, 13 Oct 2016 14:14:40 +0000
Message-ID: <BL2PR07MB2306E19AD9C9FE46992E12A78DDC0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1476019942-6837-1-git-send-email-weiyj.lk@gmail.com>
 <20161013.094725.657883863089600176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "weiyongjun1@huawei.com" <weiyongjun1@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        "weiyj.lk@gmail.com" <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0057.outbound.protection.outlook.com ([104.47.33.57]:7227
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932226AbcJMPwy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 11:52:54 -0400
In-Reply-To: <20161013.094725.657883863089600176.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Since we will remove items off the list using list_del() we need to
> > use a safe version of the list_for_each_entry() macro aptly named
> > list_for_each_entry_safe().
> >
> > Fixes: 0a7fb11c23c0 ("qed: Add Light L2 support")
> > Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
>=20
> Can the QED maintainers please review this simple fix?
>=20
> In my opinion 4 days is sufficient time in which to expect a reasonable r=
eview to
> occur, let me know if you disagree. :-)

Sorry about that; The high holy days are killing our productivity. :-(
I did ACK v1, though [and v2 was purely semantic change].
