From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [patch net-next 0/9] mlxsw: Support firmware flash
Date: Tue, 23 May 2017 15:19:48 +0000
Message-ID: <BLUPR0701MB20042C9597E9E95A494BDF6B8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170523065301.1091-1-jiri@resnulli.us>
 <BLUPR0701MB2004690F775AD57D3CACB1CC8DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <ea7cf005-1f6c-aa87-db90-03d7c77c7d56@mellanox.com>
 <BLUPR0701MB2004EB2F32B4C8C42C5020458DF90@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "idosch@mellanox.com" <idosch@mellanox.com>,
        "mlxsw@mellanox.com" <mlxsw@mellanox.com>
To: Yotam Gigi <yotamg@mellanox.com>, Jiri Pirko <jiri@resnulli.us>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0076.outbound.protection.outlook.com ([104.47.37.76]:11834
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S967289AbdEWPTy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 11:19:54 -0400
In-Reply-To: <fba5a440-ba1e-84bd-d2d2-d011406d3a4a@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >>>> Patches 6-8 add the "ethtool -f" and the boot-time firmware upgrade
> >>>> on
> >> the
> >>>> mlxsw spectrum driver.
> >>> When we tried using `ethtool -E' for qed we got burned for trying to
> >>> use
> >> the magic
> >>> value [1]. When we suggested extending it to allow some private data
> >> indications,
> >>> Ben claimed that this entire ethtool infrastructure is a thing of
> >>> the past, and we should try using MTD instead - a claim no one
> bothered to counter.
> >>>
> >>> Creating proprietary file-formats, filling them with metadata and
> >>> complementary driver state-machines could easily overcome the
> >>> original obstacle we faced. But it raises the question of whether
> >>> these APIs are valid or obsolete.
> >> The metadata in our format is needed to allow us to hold several
> >> firmware images for several spectrum silicon variants in one file,
> >> hence the metadata is used by the driver and does not get transferred =
to
> the device.
> > Understood; Otherwise it would have been 'data' and not 'metadata'.
> >
> >> Our code can only be used to transfer firmware to the device, and
> >> cannot be used to configure the device.
> > Not sure what this refers to? The differences between '-f' and '-E'?
> > Also, assuming you haven't started selling your adapters as persistent
> > memory for storage, what's the difference?
> >
>=20
> Sorry, I am not sure I understand. You think that drivers should not
> implement ethtool's flash_device callback anymore? do you have an
> alternative for firmware flash?

That's exactly the question Ben asked in -=20
http://marc.info/?l=3Dlinux-netdev&m=3D146514461214421&w=3D2
Suggesting to use MTD for flash access.

I'm not saying that approach was necessarily the best;
But no one shared any disagreement with it back then.
