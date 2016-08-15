From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: [patch net 5/9] mlxsw: spectrum: Add missing packet traps
Date: Mon, 15 Aug 2016 14:51:20 +0000
Message-ID: <AM4PR0501MB1940ACE440494A1D8018FC46DB120@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <1471271873-4389-1-git-send-email-jiri@resnulli.us>
 <1471271873-4389-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>,
	Elad Raz <eladr@mellanox.com>,
	Yotam Gigi <yotamg@mellanox.com>,
	Nogah Frankel <nogahf@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr40070.outbound.protection.outlook.com ([40.107.4.70]:12283
	"EHLO EUR03-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750791AbcHOTYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2016 15:24:51 -0400
In-Reply-To: <1471271873-4389-6-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Add the following traps:
>=20
> 1) MTU Error: Trap packets whose size is bigger than the egress RIF's MTU=
. If DF
> bit isn't set, traffic will continue to be routed in slow path.
>=20
> 2) TTL Error: Trap packets whose TTL expired. This allows traceroute to w=
ork
> properly.
>=20
> 3) OSPF packets.

Don't you need LBERROR as well?
