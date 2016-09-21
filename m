From: "Amrani, Ram" <Ram.Amrani@cavium.com>
Subject: RE: [RFC v2 06/12] qedr: Add support for QP verbs
Date: Wed, 21 Sep 2016 14:15:39 +0000
Message-ID: <SN1PR07MB2207C1EC2C5C86C607D0255AF8F60@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-7-git-send-email-Ram.Amrani@cavium.com>
 <20160920163048.GQ26673@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Borundia, Rajesh" <Rajesh.Borundia@cavium.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0050.outbound.protection.outlook.com ([104.47.42.50]:23808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934344AbcIUObK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 10:31:10 -0400
In-Reply-To: <20160920163048.GQ26673@leon.nu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  include/uapi/rdma/providers/qedr-abi.h     |   35 +
>=20
> Please be aware that the last version for ABI header files doesn't have "=
provider"
> name in directory path (include/uapi/rdma/qedr-abi.h)

OK. Note that I was using https://www.spinics.net/lists/linux-rdma/msg40414=
.html that dates to 7 days ago and it contains the "providers" folder.
Can you point to the most recent patch?

> > diff --git a/drivers/infiniband/hw/qedr/main.c
> > b/drivers/infiniband/hw/qedr/main.c
> > index c99dd6a..10ad9ed 100644
> > --- a/drivers/infiniband/hw/qedr/main.c
> > +++ b/drivers/infiniband/hw/qedr/main.c
> > @@ -52,7 +52,7 @@ uint debug;
> >  module_param(debug, uint, 0);
> >  MODULE_PARM_DESC(debug, "Default debug msglevel");
> >
> > -static LIST_HEAD(qedr_dev_list);
>=20
> You are removing code which was added in previous patches, why do you do =
it?
>=20

Sure. Will fix. Thanks.

> > diff --git a/drivers/infiniband/hw/qedr/qedr.h
> > b/drivers/infiniband/hw/qedr/qedr.h
> > index dd974d5..05017be 100644
> > --- a/drivers/infiniband/hw/qedr/qedr.h
> > +++ b/drivers/infiniband/hw/qedr/qedr.h
> > @@ -49,6 +49,9 @@
> >  enum DP_QEDR_MODULE {
> >  	QEDR_MSG_INIT =3D 0x10000,
>=20
> We prefer shift notation (1 << 16) instead of 0x10000.
>=20

OK, I'll convert accordingly.
