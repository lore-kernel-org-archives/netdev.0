From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next 01/11] qede: Fix sparse warnings
Date: Mon, 22 May 2017 17:44:12 +0000
Message-ID: <BLUPR0701MB20043F202421D02E697198338DF80@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <1495452731-27171-2-git-send-email-Yuval.Mintz@cavium.com>
        <20170522.123804.1189830414503494485.davem@davemloft.net>
        <BLUPR0701MB2004062F133B0DD22E817C6C8DF80@BLUPR0701MB2004.namprd07.prod.outlook.com>,<20170522.125430.1296201768191613727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0044.outbound.protection.outlook.com ([104.47.37.44]:3840
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757895AbdEVRoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 13:44:16 -0400
In-Reply-To: <20170522.125430.1296201768191613727.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> Please.
> >>=20
> >> This is exactly the problem when such a terse commit message, or lack =
of any
> >> message at all as is the case here, occurs.
> >>=20
> >> I have no idea what removing this method assignment has to do with fix=
ing
> >> sparse warnings.
> >=20
> > It's currently defined twice in the qede_dcbnl_ops struct -

> >Ok, so what's important is that you don't just post a patch with no
> commit message, just saying "sparse warning fixes."

> At a minimum, if you're too lazy to explain what exactly each thing
> is fixing, provide the sparse warnings you are eliminating in the
> commit message.

Well, this time it was intentional lazines; Thought it would have been
wasted reading. But sure, here it is:

drivers/net/ethernet/qlogic/qede/qede_fp.c:349:34: warning: invalid assignm=
ent: |=3D
drivers/net/ethernet/qlogic/qede/qede_fp.c:349:34:    left side has type re=
stricted __le16
drivers/net/ethernet/qlogic/qede/qede_fp.c:349:34:    right side has type i=
nt
drivers/net/ethernet/qlogic/qede/qede_fp.c:1516:50: warning: invalid assign=
ment: |=3D
drivers/net/ethernet/qlogic/qede/qede_fp.c:1516:50:    left side has type r=
estricted __le16
drivers/net/ethernet/qlogic/qede/qede_fp.c:1516:50:    right side has type =
int
drivers/net/ethernet/qlogic/qede/qede_fp.c:1525:50: warning: invalid assign=
ment: ^=3D
drivers/net/ethernet/qlogic/qede/qede_fp.c:1525:50:    left side has type r=
estricted __le16
drivers/net/ethernet/qlogic/qede/qede_fp.c:1525:50:    right side has type =
int
drivers/net/ethernet/qlogic/qede/qede_fp.c:1590:42: warning: invalid assign=
ment: |=3D
drivers/net/ethernet/qlogic/qede/qede_fp.c:1590:42:    left side has type r=
estricted __le16
drivers/net/ethernet/qlogic/qede/qede_fp.c:1590:42:    right side has type =
unsigned int
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1315:34: warning: invalid a=
ssignment: |=3D
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1315:34:    left side has t=
ype restricted __le16
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1315:34:    right side has =
type int
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1330:13: warning: incorrect=
 type in assignment (different base types)
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1330:13:    expected int [s=
igned] [assigned] val
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1330:13:    got restricted =
__le16 [usertype] <noident>
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1331:33: warning: incorrect=
 type in assignment (different base types)
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1331:33:    expected restri=
cted __le16 [usertype] bd_prod
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:1331:33:    got int [signed=
] [assigned] val
drivers/net/ethernet/qlogic/qede/qede_roce.c:224:29: warning: symbol 'qede_=
roce_get_free_event_node' was not declared. Should it be static?

Do you want us to re-spin the series with the updated commit message?

 =
