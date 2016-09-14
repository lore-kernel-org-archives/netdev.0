From: "Amrani, Ram" <Ram.Amrani@cavium.com>
Subject: RE: [RFC 07/11] Add support for memory registeration verbs
Date: Wed, 14 Sep 2016 08:02:01 +0000
Message-ID: <SN1PR07MB2207AB804FB12A2B010C56A5F8F10@SN1PR07MB2207.namprd07.prod.outlook.com>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-8-git-send-email-Ram.Amrani@qlogic.com>
 <dfff3b6a-07da-38eb-e844-a48f713ff0f7@grimberg.me>
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
Received: from mail-dm3nam03on0048.outbound.protection.outlook.com ([104.47.41.48]:31392
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759814AbcINIRm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 04:17:42 -0400
In-Reply-To: <dfff3b6a-07da-38eb-e844-a48f713ff0f7@grimberg.me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static inline struct qedr_ah *get_qedr_ah(struct ib_ah *ibah) {
> > +	return container_of(ibah, struct qedr_ah, ibah); }
>=20
> Little surprising to find that here... how is the ah related to this patc=
h?

Thanks, Sagi. Will move into a proper location.
