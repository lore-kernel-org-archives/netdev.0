From: Alexander Kochetkov <al.kochet@gmail.com>
Subject: Re: [PATCH] net: arc_emac: switch to phy_start()/phy_stop()
Date: Thu, 20 Apr 2017 00:19:11 +0300
Message-ID: <E5D835FF-589E-4A87-9C08-A47B2CCF5645@gmail.com>
References: <1492612195-16601-1-git-send-email-al.kochet@gmail.com> <5ed9e534-d134-2ba1-0276-0bc8bd949eb1@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Peter Chen <peter.chen@nxp.com>,
        Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36041 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967507AbdDSVTO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 17:19:14 -0400
In-Reply-To: <5ed9e534-d134-2ba1-0276-0bc8bd949eb1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 20 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 0:08, Florian Fainelli =
<f.fainelli@gmail.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB(=D0=B0):=

>=20
> This looks fine. If you wanted to go further, you could move the
> phy_connect(), phy_disconnect() calls down to the arc_emac_open()
> respectively arc_emac_stop() as this would also allow the PHY device =
to
> be fully suspended when the interface is unused.


I=E2=80=99ve checked patch phy_connect() is called from arc_emac_open() =
and
phy_disconnect() is called from arc_emac_stop().

So, I=E2=80=99ve made mistake in the commit message.

Thank you for review.

>=20
> 19 =D0=B0=D0=BF=D1=80. 2017 =D0=B3., =D0=B2 21:22, Sergei Shtylyov =
<sergei.shtylyov@cogentembedded.com> =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=
=BB(=D0=B0):
>=20
> On 04/19/2017 05:29 PM, Alexander Kochetkov wrote:
>=20
>> The patch replace phy_start_aneg() with phy_start(). phy_start() call
>=20
>   Replaces.
>=20
>> phy_start_aneg() as a part of startup sequence and allow recover from
>> error (PHY_HALTED) state.
>>=20
>> Also added call phy_stop() to arc_emac_remove() to stop PHY state =
machine
>=20
>   To arc_emac_stop() maybe?
>=20

Sergei, thanks for spell and gramma checking.

Regards,
Alexander.
