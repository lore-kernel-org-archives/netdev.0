From: "Amrani, Ram" <Ram.Amrani@cavium.com>
Subject: RE: [RFC 03/11] Add support for RoCE HW init
Date: Wed, 14 Sep 2016 10:13:21 +0000
Message-ID: <SN1PR07MB2207238CD2D8CD3A8C5EE36CF8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-4-git-send-email-Ram.Amrani@qlogic.com>
 <29e0d88d-63f2-2b30-2856-a0e94cf31f8e@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Yuval.Mintz@qlogic.com" <Yuval.Mintz@qlogic.com>,
        "Ariel.Elior@qlogic.com" <Ariel.Elior@qlogic.com>,
        "Michal.Kalderon@qlogic.com" <Michal.Kalderon@qlogic.com>,
        "rajesh.borundia@qlogic.com" <rajesh.borundia@qlogic.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0051.outbound.protection.outlook.com ([104.47.40.51]:17673
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751621AbcINKNY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 06:13:24 -0400
In-Reply-To: <29e0d88d-63f2-2b30-2856-a0e94cf31f8e@grimberg.me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +	dev->max_sge =3D min_t(u32, RDMA_MAX_SGE_PER_SQ_WQE,
> > +			     RDMA_MAX_SGE_PER_RQ_WQE);
>=20
> Our kernel target mode consumers sort of rely on max_sge_rd, you need to
> make sure to set it too.
Good catch. Thanks!
