From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v2] rocker: add debugfs support to dump internal tables
Date: Mon, 17 Aug 2015 01:02:33 -0700
Message-ID: <CAE4R7bDZTmNN-R4XB8KEd-AXtti7wRN=OPOca96e9j96Vbp1jg@mail.gmail.com>
References: <1439782326-14996-1-git-send-email-sfeldma@gmail.com> <20150817063622.GC2171@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:33089 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbbHQICy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 04:02:54 -0400
Received: by obbhe7 with SMTP id he7so105986757obb.0
        for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 01:02:53 -0700 (PDT)
In-Reply-To: <20150817063622.GC2171@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 16, 2015 at 11:36 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Aug 17, 2015 at 05:32:06AM CEST, sfeldma@gmail.com wrote:
>>From: Scott Feldman <sfeldma@gmail.com>
>>
>>> tree /sys/kernel/debug/rocker
>>/sys/kernel/debug/rocker
>>=E2=94=94=E2=94=80=E2=94=80 5254001235010000
>>    =E2=94=9C=E2=94=80=E2=94=80 fdb_tbl
>>    =E2=94=9C=E2=94=80=E2=94=80 internal_vlan_tbl
>>    =E2=94=9C=E2=94=80=E2=94=80 neigh_tbl
>>    =E2=94=9C=E2=94=80=E2=94=80 of_dpa_flow_tbl
>>    =E2=94=94=E2=94=80=E2=94=80 of_dpa_group_tbl
>>
>>1 directory, 5 files
>>
>>> cat /sys/kernel/debug/rocker/5254001235010000/internal_vlan_tbl
>>ifindex 5 ref_count 1 vlan 3843
>>ifindex 7 ref_count 2 vlan 3840
>>ifindex 4 ref_count 1 vlan 3842
>>
>>> cat /sys/kernel/debug/rocker/5254001235010000/fdb_tbl
>>learned 1 pport 1 addr 00:02:00:00:02:00 vlan 3840
>>learned 1 pport 2 addr 00:02:00:00:03:00 vlan 3840
>>
>>> cat /sys/kernel/debug/rocker/5254001235010000/neigh_tbl
>>11.0.0.9 dev sw1p2 ref_count 3 index 1 dst 00:02:00:00:01:00 ttl_chec=
k 1
>>11.0.0.1 dev sw1p1 ref_count 3 index 0 dst 00:02:00:00:00:00 ttl_chec=
k 1
>>
>>> cat /sys/kernel/debug/rocker/5254001235010000/of_dpa_flow_tbl
>>cmd 3 cookie 15 priority 3  tbl acl            in_pport 2 01:80:c2:00=
:00:00/ff:ff:ff:ff:ff:f0 eth_type 0x0000 vlan_id 3841 ip proto 0/0 ip t=
os 0/0 group_id 0x0f010000
>>cmd 3 cookie 2  priority 0  tbl term_mac       in_pport 1 eth_type 0x=
0800 52:54:00:12:35:01 vlan_id 3840 goto_tbl ucast_routing copy_to_cpu =
0
>>cmd 3 cookie 1f priority 3  tbl bridge         00:02:00:00:00:00 vlan=
_id 3840 tunnel_id 0 goto_tbl acl group_id 0x00000000 copy_to_cpu 0
>>cmd 3 cookie 4  priority 1  tbl vlan           in_pport 2 vlan_id 0 g=
oto_tbl term_mac untagged 1 new_vlan_id 3841
>>cmd 3 cookie 20 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E1 goto_tbl acl group_id 0x20000000
>>cmd 3 cookie 21 priority 3  tbl bridge         00:02:00:00:01:00 vlan=
_id 3841 tunnel_id 0 goto_tbl acl group_id 0x00000000 copy_to_cpu 0
>>cmd 3 cookie 16 priority 2  tbl acl            in_pport 2 eth_type 0x=
0806 vlan_id 3841 ip proto 0/0 ip tos 0/0 group_id 0x0f010000
>>cmd 3 cookie 12 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E0 goto_tbl acl group_id 0x0f000000
>>cmd 3 cookie 9  priority 3  tbl acl            in_pport 1 01:80:c2:00=
:00:00/ff:ff:ff:ff:ff:f0 eth_type 0x0000 vlan_id 3840 ip proto 0/0 ip t=
os 0/0 group_id 0x0f000000
>>cmd 3 cookie 6  priority 0  tbl term_mac       in_pport 2 eth_type 0x=
86dd 52:54:00:12:35:02 vlan_id 3841 goto_tbl ucast_routing copy_to_cpu =
0
>>cmd 4 cookie 0  priority 1  tbl ig_port        in_pport 0/0xffff0000 =
goto_tbl vlan
>>cmd 4 cookie e  priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E3 goto_tbl acl group_id 0x0f000000
>>cmd 3 cookie 1  priority 1  tbl vlan           in_pport 1 vlan_id 0 g=
oto_tbl term_mac untagged 1 new_vlan_id 3840
>>cmd 3 cookie 24 priority 20 tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E4/255.255.255.252 goto_tbl acl group_id 0x20000000
>>cmd 4 cookie 14 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E10 goto_tbl acl group_id 0x0f010000
>>cmd 3 cookie 2c priority 20 tbl ucast_routing  eth_type 0x0800 12.0.0=
=2E4 goto_tbl acl group_id 0x20000001
>>cmd 3 cookie 17 priority 1  tbl term_mac       in_pport 2 eth_type 0x=
0800 01:00:5e:00:00:00/ff:ff:ff:80:00:00 vlan_id 3841 goto_tbl mcast_ro=
uting copy_to_cpu 1
>>cmd 3 cookie 26 priority 20 tbl ucast_routing  eth_type 0x0800 12.0.0=
=2E3 goto_tbl acl group_id 0x20000000
>>cmd 3 cookie 2e priority 30 tbl ucast_routing  eth_type 0x0800 12.0.0=
=2E2 goto_tbl acl group_id 0x0f010000
>>cmd 3 cookie 22 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E9 goto_tbl acl group_id 0x20000001
>>cmd 3 cookie 1c priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E8/255.255.255.252 goto_tbl acl group_id 0x0f010000
>>cmd 3 cookie 18 priority 1  tbl term_mac       in_pport 2 eth_type 0x=
86dd 33:33:00:00:00:00/ff:ff:00:00:00:00 vlan_id 3841 goto_tbl mcast_ro=
uting copy_to_cpu 1
>>cmd 3 cookie 5  priority 0  tbl term_mac       in_pport 2 eth_type 0x=
0800 52:54:00:12:35:02 vlan_id 3841 goto_tbl ucast_routing copy_to_cpu =
0
>>cmd 3 cookie a  priority 2  tbl acl            in_pport 1 eth_type 0x=
0806 vlan_id 3840 ip proto 0/0 ip tos 0/0 group_id 0x0f000000
>>cmd 4 cookie 1a priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E11 goto_tbl acl group_id 0x0f010000
>>cmd 3 cookie 1e priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E8 goto_tbl acl group_id 0x0f010000
>>cmd 3 cookie 3  priority 0  tbl term_mac       in_pport 1 eth_type 0x=
86dd 52:54:00:12:35:01 vlan_id 3840 goto_tbl ucast_routing copy_to_cpu =
0
>>cmd 3 cookie b  priority 1  tbl term_mac       in_pport 1 eth_type 0x=
0800 01:00:5e:00:00:00/ff:ff:ff:80:00:00 vlan_id 3840 goto_tbl mcast_ro=
uting copy_to_cpu 1
>>cmd 4 cookie 8  priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E2 goto_tbl acl group_id 0x0f000000
>>cmd 3 cookie 10 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E0/255.255.255.252 goto_tbl acl group_id 0x0f000000
>>cmd 3 cookie 28 priority 20 tbl ucast_routing  eth_type 0x0800 11.0.0=
=2E12/255.255.255.252 goto_tbl acl group_id 0x20000001
>>cmd 3 cookie c  priority 1  tbl term_mac       in_pport 1 eth_type 0x=
86dd 33:33:00:00:00:00/ff:ff:00:00:00:00 vlan_id 3840 goto_tbl mcast_ro=
uting copy_to_cpu 1
>>
>>> cat /sys/kernel/debug/rocker/5254001235010000/of_dpa_group_tbl
>>cmd 7 group_id 0x0f000000 (L2 interface vlan 3840 port 0) pop_vlan 1
>>cmd 7 group_id 0x0f010000 (L2 interface vlan 3841 port 0) pop_vlan 1
>>cmd 7 group_id 0x20000000 (L3 unicast index 0) src 52:54:00:12:35:01 =
dst 00:02:00:00:00:00 vlan 3840 ttl_check 1 group_id 0x0f000001
>>cmd 7 group_id 0x0f010002 (L2 interface vlan 3841 port 2) pop_vlan 1
>>cmd 7 group_id 0x0f000001 (L2 interface vlan 3840 port 1) pop_vlan 1
>>cmd 8 group_id 0x20000001 (L3 unicast index 1) src 52:54:00:12:35:02 =
dst 00:02:00:00:01:00 vlan 3841 ttl_check 1 group_id 0x0f010002
>>
>>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>>---
>>v2: wrap feature with CONFIG_ROCKER_DEBUGFS to allow config-time
>>    enable/disable
>>
>> drivers/net/ethernet/rocker/Kconfig  |    8 +
>> drivers/net/ethernet/rocker/rocker.c |  397 ++++++++++++++++++++++++=
++++++++++
>> drivers/net/ethernet/rocker/rocker.h |    2 +-
>> 3 files changed, 406 insertions(+), 1 deletion(-)
>>
>>diff --git a/drivers/net/ethernet/rocker/Kconfig b/drivers/net/ethern=
et/rocker/Kconfig
>>index b9952ef..8fcbcff 100644
>>--- a/drivers/net/ethernet/rocker/Kconfig
>>+++ b/drivers/net/ethernet/rocker/Kconfig
>>@@ -24,4 +24,12 @@ config ROCKER
>>         To compile this driver as a module, choose M here: the
>>         module will be called rocker.
>>
>>+config ROCKER_DEBUGFS
>>+      bool "Enable debugfs for rocker"
>>+      depends on ROCKER
>>+      depends on DEBUG_FS
>
> Is this necessary? Why don't just ignore retvals of debugfs_create_di=
r
> and such functions?

Hmmm....good point, looks unnecessary.  I'll revert back to v1 and
confirm everything is OK with CONFIG_DEBUG_FS=3Dn.
