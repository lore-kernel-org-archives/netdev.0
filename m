From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next 0/4] bonding: final set of netlink patches
Date: Sat, 28 Dec 2013 23:11:50 +0800
Message-ID: <52BEEA36.7030204@gmail.com>
References: <20131228065712.6296.34291.stgit@monster-03.cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, jiri@resnulli.us
To: Scott Feldman <sfeldma@cumulusnetworks.com>, vfalico@redhat.com,
	fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62333 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754677Ab3L1PXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 10:23:36 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so9950749pde.13
        for <netdev@vger.kernel.org>; Sat, 28 Dec 2013 07:23:36 -0800 (PST)
In-Reply-To: <20131228065712.6296.34291.stgit@monster-03.cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/12/28 15:15, Scott Feldman =E5=86=99=E9=81=93:
> The following series implements the last set of bonding netlink attri=
butes
> for 802.3ad mode:
>=20
> 	lacp_rate
> 	ad_select
> 	ad_info, nest of:
> 		ad_aggregator
> 		ad_num_ports
> 		ad_actor_key
> 		ad_partner_key
> 		ad_partner_mac
>=20
> The last patch adds an additional netlink attribute, active_slaves, w=
hich
> is a nested list of ifindices for current active slaves.  We're using=
 this
> list to enable/disable hashing of ports in a hardware LAG implementat=
ion.
> In the same way bonding driver includes/excludes ports for 802.3ad eg=
ress
> hashing, hardware ports are included/excluded from egress hashing by
> hardware based on port active status.  Yes, data path offloaded to
> hardware, control path remains in kernel via bonding driver.
>=20
> ---
>=20
> Scott Feldman (4):
>       bonding: add lacp_rate attribute netlink support
>       bonding: add ad_select attribute netlink support
>       bonding: add ad_info attribute netlink support
>       bonding: add active_slaves attribute
>=20
>=20
>  drivers/net/bonding/bond_netlink.c |  100 ++++++++++++++++++++++++++=
+++++++
>  drivers/net/bonding/bond_options.c |   51 +++++++++++++++++
>  drivers/net/bonding/bond_sysfs.c   |  108 +++++++++++++++++++++-----=
----------
>  drivers/net/bonding/bonding.h      |    2 +
>  include/uapi/linux/if_link.h       |   15 +++++
>  5 files changed, 229 insertions(+), 47 deletions(-)
>=20

Reviewed-by: Ding Tianhong <dingtianhong@huawei.com>
