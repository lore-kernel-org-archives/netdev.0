From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Subject: RE: [PATCH net-next 3/5] liquidio CN23XX: Mailbox support
Date: Wed, 14 Sep 2016 01:25:10 +0000
Message-ID: <DM3PR07MB2138932DA3ADB67A07856E7381F10@DM3PR07MB2138.namprd07.prod.outlook.com>
References: <1473451707-26397-1-git-send-email-rvatsavayi@caviumnetworks.com>
        <1473451707-26397-4-git-send-email-rvatsavayi@caviumnetworks.com>
 <20160910.214201.116857018916997521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chickles, Derek" <Derek.Chickles@cavium.com>,
        "Burla, Satananda" <Satananda.Burla@cavium.com>,
        "Manlunas, Felix" <Felix.Manlunas@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0049.outbound.protection.outlook.com ([104.47.37.49]:41933
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750975AbcINBZO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 21:25:14 -0400
In-Reply-To: <20160910.214201.116857018916997521.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sure Dave, Will submit new patches with these changes.
Thanks
Raghu.

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, September 10, 2016 9:42 PM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org; Chickles, Derek; Burla, Satananda; Manlunas,
> Felix; Vatsavayi, Raghu
> Subject: Re: [PATCH net-next 3/5] liquidio CN23XX: Mailbox support
>=20
> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> Date: Fri, 9 Sep 2016 13:08:25 -0700
>=20
> > +int octeon_mbox_read(struct octeon_mbox *mbox) {
> > +	int ret =3D 0;
> > +	union octeon_mbox_message msg;
> > +
>=20
> Please always order local variable declarations from longest to shortest =
line.
>=20
> Please audit your entire submission for this problem.
