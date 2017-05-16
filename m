From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: cxgb4 is broken in v4.12-rc1
Date: Tue, 16 May 2017 15:19:35 +0000
Message-ID: <CY4PR12MB1432E4FA04313105999F04FAC1E60@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <f5966da1-44e7-ebf7-c5df-28f815a77424@deltatee.com>
 <CY4PR12MB1432CA69BD6B7AE335B5DBB2C1E60@CY4PR12MB1432.namprd12.prod.outlook.com>,<745b4343-52e7-b8c7-0889-98ea843de15b@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Bates <sbates@raithlin.com>,
        SWise OGC <swise@opengridcomputing.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Logan Gunthorpe <logang@deltatee.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0096.outbound.protection.outlook.com ([104.47.36.96]:3728
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751030AbdEPPTg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 11:19:36 -0400
In-Reply-To: <745b4343-52e7-b8c7-0889-98ea843de15b@deltatee.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Logan,

The latest firmware available is 1.16.43.0 kindly update your firmware and
give a try, 1.16.29.4 have no support for autoneg.

Thanks
Ganesh






From: Logan Gunthorpe <logang@deltatee.com>
Sent: Tuesday, May 16, 2017 7:20 AM
To: Ganesh GR
Cc: David S. Miller; Stephen Bates; SWise OGC; netdev@vger.kernel.org
Subject: Re: cxgb4 is broken in v4.12-rc1
=A0  =20
Hi,

Thanks for looking into it. The version information of the card is:

[=A0=A0=A0 5.235956] cxgb4 0000:07:00.4: Chelsio T62100-LP-CR rev 0
[=A0=A0=A0 5.235957] cxgb4 0000:07:00.4: S/N: PT51160053, P/N: 11012106004
[=A0=A0=A0 5.235959] cxgb4 0000:07:00.4: Firmware version: 1.16.29.4
[=A0=A0=A0 5.235960] cxgb4 0000:07:00.4: Bootstrap version: 255.255.255.255
[=A0=A0=A0 5.235961] cxgb4 0000:07:00.4: TP Microcode version: 0.1.23.2

Logan


On 15/05/17 07:00 PM, Ganesh GR wrote:
>=20
> Hi Logan,
>=20
> Thanks for reporting the issue I will try to reproduce this, btw what is =
the firmware version
> on your setup?.
>=20
> Regards
> Ganesh
>=20
>=20
>=20
>=20
> From: Logan Gunthorpe <logang@deltatee.com>
> Sent: Tuesday, May 16, 2017 4:06 AM
> To: Ganesh GR
> Cc: David S. Miller; Stephen Bates; SWise OGC; netdev@vger.kernel.org
> Subject: BUG: cxgb4 is broken in v4.12-rc1
>=A0=A0=A0=A0=20
> Hi,
>=20
> With rc1 my T62100-LP-CR no longer functions correctly. Everything
> appears fine but the link never goes into the UP state. I have one peer
> with an older (functioning) kernel and the other peer on rc1.
>=20
> I've bisected to find this is the offending commit:
>=20
> 3bb4858fd: cxgb4: avoid disabling FEC by default
>=20
> I've also attached a bisect log.
>=20
> Let me know if you need anything else.
>=20
> Thanks,
>=20
> Logan
>=A0=A0=A0=A0=20
>=20
    =
