From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3] rocker: add debugfs support to dump internal
 tables
Date: Tue, 18 Aug 2015 07:55:55 +0200
Message-ID: <20150818055555.GA2200@nanopsycho.orion>
References: <1439850977-31079-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35695 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbHRFz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 01:55:58 -0400
Received: by wicne3 with SMTP id ne3so85988961wic.0
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 22:55:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1439850977-31079-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 18, 2015 at 12:36:17AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>> tree /sys/kernel/debug/rocker
>/sys/kernel/debug/rocker
>=E2=94=94=E2=94=80=E2=94=80 5254001235010000
>    =E2=94=9C=E2=94=80=E2=94=80 fdb_tbl
>    =E2=94=9C=E2=94=80=E2=94=80 internal_vlan_tbl
>    =E2=94=9C=E2=94=80=E2=94=80 neigh_tbl
>    =E2=94=9C=E2=94=80=E2=94=80 of_dpa_flow_tbl
>    =E2=94=94=E2=94=80=E2=94=80 of_dpa_group_tbl
>
>1 directory, 5 files
>
>> cat /sys/kernel/debug/rocker/5254001235010000/internal_vlan_tbl
>ifindex 5 ref_count 1 vlan 3843
>ifindex 7 ref_count 2 vlan 3840
>ifindex 4 ref_count 1 vlan 3842
>
>> cat /sys/kernel/debug/rocker/5254001235010000/fdb_tbl
>learned 1 pport 1 addr 00:02:00:00:02:00 vlan 3840
>learned 1 pport 2 addr 00:02:00:00:03:00 vlan 3840
>
>> cat /sys/kernel/debug/rocker/5254001235010000/neigh_tbl
>11.0.0.9 dev sw1p2 ref_count 3 index 1 dst 00:02:00:00:01:00 ttl_check=
 1
>11.0.0.1 dev sw1p1 ref_count 3 index 0 dst 00:02:00:00:00:00 ttl_check=
 1
>
>> cat /sys/kernel/debug/rocker/5254001235010000/of_dpa_flow_tbl
>cmd 3 cookie 15 priority 3  tbl acl            in_pport 2 01:80:c2:00:=
00:00/ff:ff:ff:ff:ff:f0 eth_type 0x0000 vlan_id 3841 ip proto 0/0 ip to=
s 0/0 group_id 0x0f010000
>cmd 3 cookie 2  priority 0  tbl term_mac       in_pport 1 eth_type 0x0=
800 52:54:00:12:35:01 vlan_id 3840 goto_tbl ucast_routing copy_to_cpu 0
>cmd 3 cookie 1f priority 3  tbl bridge         00:02:00:00:00:00 vlan_=
id 3840 tunnel_id 0 goto_tbl acl group_id 0x00000000 copy_to_cpu 0
>cmd 3 cookie 4  priority 1  tbl vlan           in_pport 2 vlan_id 0 go=
to_tbl term_mac untagged 1 new_vlan_id 3841
>cmd 3 cookie 20 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
1 goto_tbl acl group_id 0x20000000
>cmd 3 cookie 21 priority 3  tbl bridge         00:02:00:00:01:00 vlan_=
id 3841 tunnel_id 0 goto_tbl acl group_id 0x00000000 copy_to_cpu 0
>cmd 3 cookie 16 priority 2  tbl acl            in_pport 2 eth_type 0x0=
806 vlan_id 3841 ip proto 0/0 ip tos 0/0 group_id 0x0f010000
>cmd 3 cookie 12 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
0 goto_tbl acl group_id 0x0f000000
>cmd 3 cookie 9  priority 3  tbl acl            in_pport 1 01:80:c2:00:=
00:00/ff:ff:ff:ff:ff:f0 eth_type 0x0000 vlan_id 3840 ip proto 0/0 ip to=
s 0/0 group_id 0x0f000000
>cmd 3 cookie 6  priority 0  tbl term_mac       in_pport 2 eth_type 0x8=
6dd 52:54:00:12:35:02 vlan_id 3841 goto_tbl ucast_routing copy_to_cpu 0
>cmd 4 cookie 0  priority 1  tbl ig_port        in_pport 0/0xffff0000 g=
oto_tbl vlan
>cmd 4 cookie e  priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
3 goto_tbl acl group_id 0x0f000000
>cmd 3 cookie 1  priority 1  tbl vlan           in_pport 1 vlan_id 0 go=
to_tbl term_mac untagged 1 new_vlan_id 3840
>cmd 3 cookie 24 priority 20 tbl ucast_routing  eth_type 0x0800 11.0.0.=
4/255.255.255.252 goto_tbl acl group_id 0x20000000
>cmd 4 cookie 14 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
10 goto_tbl acl group_id 0x0f010000
>cmd 3 cookie 2c priority 20 tbl ucast_routing  eth_type 0x0800 12.0.0.=
4 goto_tbl acl group_id 0x20000001
>cmd 3 cookie 17 priority 1  tbl term_mac       in_pport 2 eth_type 0x0=
800 01:00:5e:00:00:00/ff:ff:ff:80:00:00 vlan_id 3841 goto_tbl mcast_rou=
ting copy_to_cpu 1
>cmd 3 cookie 26 priority 20 tbl ucast_routing  eth_type 0x0800 12.0.0.=
3 goto_tbl acl group_id 0x20000000
>cmd 3 cookie 2e priority 30 tbl ucast_routing  eth_type 0x0800 12.0.0.=
2 goto_tbl acl group_id 0x0f010000
>cmd 3 cookie 22 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
9 goto_tbl acl group_id 0x20000001
>cmd 3 cookie 1c priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
8/255.255.255.252 goto_tbl acl group_id 0x0f010000
>cmd 3 cookie 18 priority 1  tbl term_mac       in_pport 2 eth_type 0x8=
6dd 33:33:00:00:00:00/ff:ff:00:00:00:00 vlan_id 3841 goto_tbl mcast_rou=
ting copy_to_cpu 1
>cmd 3 cookie 5  priority 0  tbl term_mac       in_pport 2 eth_type 0x0=
800 52:54:00:12:35:02 vlan_id 3841 goto_tbl ucast_routing copy_to_cpu 0
>cmd 3 cookie a  priority 2  tbl acl            in_pport 1 eth_type 0x0=
806 vlan_id 3840 ip proto 0/0 ip tos 0/0 group_id 0x0f000000
>cmd 4 cookie 1a priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
11 goto_tbl acl group_id 0x0f010000
>cmd 3 cookie 1e priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
8 goto_tbl acl group_id 0x0f010000
>cmd 3 cookie 3  priority 0  tbl term_mac       in_pport 1 eth_type 0x8=
6dd 52:54:00:12:35:01 vlan_id 3840 goto_tbl ucast_routing copy_to_cpu 0
>cmd 3 cookie b  priority 1  tbl term_mac       in_pport 1 eth_type 0x0=
800 01:00:5e:00:00:00/ff:ff:ff:80:00:00 vlan_id 3840 goto_tbl mcast_rou=
ting copy_to_cpu 1
>cmd 4 cookie 8  priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
2 goto_tbl acl group_id 0x0f000000
>cmd 3 cookie 10 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.=
0/255.255.255.252 goto_tbl acl group_id 0x0f000000
>cmd 3 cookie 28 priority 20 tbl ucast_routing  eth_type 0x0800 11.0.0.=
12/255.255.255.252 goto_tbl acl group_id 0x20000001
>cmd 3 cookie c  priority 1  tbl term_mac       in_pport 1 eth_type 0x8=
6dd 33:33:00:00:00:00/ff:ff:00:00:00:00 vlan_id 3840 goto_tbl mcast_rou=
ting copy_to_cpu 1
>
>> cat /sys/kernel/debug/rocker/5254001235010000/of_dpa_group_tbl
>cmd 7 group_id 0x0f000000 (L2 interface vlan 3840 port 0) pop_vlan 1
>cmd 7 group_id 0x0f010000 (L2 interface vlan 3841 port 0) pop_vlan 1
>cmd 7 group_id 0x20000000 (L3 unicast index 0) src 52:54:00:12:35:01 d=
st 00:02:00:00:00:00 vlan 3840 ttl_check 1 group_id 0x0f000001
>cmd 7 group_id 0x0f010002 (L2 interface vlan 3841 port 2) pop_vlan 1
>cmd 7 group_id 0x0f000001 (L2 interface vlan 3840 port 1) pop_vlan 1
>cmd 8 group_id 0x20000001 (L3 unicast index 1) src 52:54:00:12:35:02 d=
st 00:02:00:00:01:00 vlan 3841 ttl_check 1 group_id 0x0f010002
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
>v3: undo v2 change: Jiri is right: debugfs calls are no-ops when
>    CONFIG_DEBUG_FS=3Dn so we don't need to do anything extra in the
>    CONFIG_DEBUG_FS=3Dn case.  v3 has adds a few wrapper funcs around =
the
>    debugfs calls to keep mainline funcs clean, so let's go with this
>    version over v1.
>
>v2: wrap feature with CONFIG_ROCKER_DEBUGFS to allow config-time
>    enable/disable
>
> drivers/net/ethernet/rocker/rocker.c |  379 +++++++++++++++++++++++++=
+++++++++
> drivers/net/ethernet/rocker/rocker.h |    2 +-
> 2 files changed, 380 insertions(+), 1 deletion(-)
>

<snip>

>+static int rocker_probe_debugfs_init(struct rocker *rocker)
>+{
>+	char dbg_dir_name[sizeof(rocker->hw.id) * 2 + 1];
>+
>+	sprintf(dbg_dir_name, "%*phN", (int)sizeof(rocker->hw.id),
>+		&rocker->hw.id);

You can use PCI address here. Might be better.


>+	rocker->dbg_dir =3D debugfs_create_dir(dbg_dir_name, rocker_dbg_root=
);
>+	if (!rocker->dbg_dir)

You still check the retval here and=20


>+		return -ENOMEM;
>+	return 0;
>+}
>+

<snip>

>+static int rocker_debugfs_init(void)
>+{
>+	rocker_dbg_root =3D debugfs_create_dir(rocker_driver_name, NULL);
>+	if (!rocker_dbg_root)

here. When debugfs is not enabled, init will fail.
