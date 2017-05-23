From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 15:04:23 +0000
Message-ID: <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170523065301.1091-1-jiri@resnulli.us>
 <BLUPR0701MB2004690F775AD57D3CACB1CC8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>,
        Ben Hutchings <bhutchings@solarflare.com>
To: Yotam Gigi <yotamg@mellanox.com>, Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0052.outbound.protection.outlook.com ([104.47.34.52]:23840
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1762352AbdEWPE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 11:04:26 -0400
In-Reply-To: <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> Patches 6-8 add the "ethtool -f" and the boot-time firmware upgrade on
> the
> >> mlxsw spectrum driver.
> > When we tried using `ethtool -E' for qed we got burned for trying to us=
e
> the magic
> > value [1]. When we suggested extending it to allow some private data
> indications,
> > Ben claimed that this entire ethtool infrastructure is a thing of the p=
ast,
> > and we should try using MTD instead - a claim no one bothered to counte=
r.
> >
> > Creating proprietary file-formats, filling them with metadata and
> > complementary driver state-machines could easily overcome the original
> > obstacle we faced. But it raises the question of whether these APIs are
> > valid or obsolete.
>=20
> The metadata in our format is needed to allow us to hold several firmware
> images for several spectrum silicon variants in one file, hence the metad=
ata
> is used by the driver and does not get transferred to the device.

Understood; Otherwise it would have been 'data' and not 'metadata'.

>Our code can only be used to transfer firmware to the device, and cannot
> be used to configure the device.

Not sure what this refers to? The differences between '-f' and '-E'?
Also, assuming you haven't started selling your adapters as persistent memo=
ry
for storage, what's the difference?
