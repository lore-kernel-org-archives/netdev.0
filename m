From: Parav Pandit <parav@mellanox.com>
Subject: RE: [PATCH] net-next: treewide use is_vlan_dev() helper function.
Date: Sat, 4 Feb 2017 16:47:14 +0000
Message-ID: <VI1PR0502MB300889FE34A841AD7C84EAE7D14E0@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <1486182386-50797-1-git-send-email-parav@mellanox.com>
 <1486185045.22276.79.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "sean.hefty@intel.com" <sean.hefty@intel.com>,
        "hal.rosenstock@gmail.com" <hal.rosenstock@gmail.com>,
        Moni Shoua <monis@mellanox.com>,
        "santosh@chelsio.com" <santosh@chelsio.com>,
        "ganeshgr@chelsio.com" <ganeshgr@chelsio.com>,
        "manish.chopra@cavium.com" <manish.chopra@cavium.com>,
        "rahul.verma@cavium.com" <rahul.verma@cavium.com>,
        "Dept-GELinuxNICDev@cavium.com" <Dept-GELinuxNICDev@cavium.com>,
        "harish.patil@cavium.com" <harish.patil@cavium.com>,
        kys <kys@microsoft.com>,
        "haiyangz@microsoft.com" <haiyangz@microsoft.com>,
        "sthemmin@microsoft.com" <sthemmin@microsoft.com>,
        "QLogic-Storage-Upstream@qlogic.com"
        <QLogic-Storage-Upstream@qlogic.com>,
        "jejb@linux.vnet.ibm.com" <jejb@linux.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0078.outbound.protection.outlook.com ([104.47.2.78]:35777
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750851AbdBDQrX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 4 Feb 2017 11:47:23 -0500
In-Reply-To: <1486185045.22276.79.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> On Fri, 2017-02-03 at 22:26 -0600, Parav Pandit wrote:
> > This patch makes use of is_vlan_dev() function instead of flag
> > comparison which is exactly done by is_vlan_dev() helper function.
>=20
> Thanks.
>=20
> btw:  after applying this patch, there is one left
>
I am sending v1 to cover it as well.

> $ git grep -E -n "&\s*IFF_802_1Q_VLAN\b" -- "*.c"
> drivers/net/ethernet/chelsio/cxgb4/l2t.c:435:   if (neigh->dev->priv_flag=
s &
> IFF_802_1Q_VLAN)
