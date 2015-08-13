From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: add debugfs support to dump internal tables
Date: Thu, 13 Aug 2015 08:35:16 -0700
Message-ID: <1439480116-41701-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:32892 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820AbbHMPco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 11:32:44 -0400
Received: by pdrh1 with SMTP id h1so20976553pdr.0
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 08:32:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Scott Feldman <sfeldma@gmail.com>

> tree /sys/kernel/debug/rocker
/sys/kernel/debug/rocker
=E2=94=94=E2=94=80=E2=94=80 5254001235010000
    =E2=94=9C=E2=94=80=E2=94=80 fdb_tbl
    =E2=94=9C=E2=94=80=E2=94=80 internal_vlan_tbl
    =E2=94=9C=E2=94=80=E2=94=80 neigh_tbl
    =E2=94=9C=E2=94=80=E2=94=80 of_dpa_flow_tbl
    =E2=94=94=E2=94=80=E2=94=80 of_dpa_group_tbl

1 directory, 5 files

> cat /sys/kernel/debug/rocker/5254001235010000/internal_vlan_tbl
ifindex 5 ref_count 1 vlan 3843
ifindex 7 ref_count 2 vlan 3840
ifindex 4 ref_count 1 vlan 3842

> cat /sys/kernel/debug/rocker/5254001235010000/fdb_tbl
learned 1 pport 1 addr 00:02:00:00:02:00 vlan 3840
learned 1 pport 2 addr 00:02:00:00:03:00 vlan 3840

> cat /sys/kernel/debug/rocker/5254001235010000/neigh_tbl
11.0.0.9 dev sw1p2 ref_count 3 index 1 dst 00:02:00:00:01:00 ttl_check =
1
11.0.0.1 dev sw1p1 ref_count 3 index 0 dst 00:02:00:00:00:00 ttl_check =
1

> cat /sys/kernel/debug/rocker/5254001235010000/of_dpa_flow_tbl
cmd 3 cookie 15 priority 3  tbl acl            in_pport 2 01:80:c2:00:0=
0:00/ff:ff:ff:ff:ff:f0 eth_type 0x0000 vlan_id 3841 ip proto 0/0 ip tos=
 0/0 group_id 0x0f010000
cmd 3 cookie 2  priority 0  tbl term_mac       in_pport 1 eth_type 0x08=
00 52:54:00:12:35:01 vlan_id 3840 goto_tbl ucast_routing copy_to_cpu 0
cmd 3 cookie 1f priority 3  tbl bridge         00:02:00:00:00:00 vlan_i=
d 3840 tunnel_id 0 goto_tbl acl group_id 0x00000000 copy_to_cpu 0
cmd 3 cookie 4  priority 1  tbl vlan           in_pport 2 vlan_id 0 got=
o_tbl term_mac untagged 1 new_vlan_id 3841
cmd 3 cookie 20 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.1=
 goto_tbl acl group_id 0x20000000
cmd 3 cookie 21 priority 3  tbl bridge         00:02:00:00:01:00 vlan_i=
d 3841 tunnel_id 0 goto_tbl acl group_id 0x00000000 copy_to_cpu 0
cmd 3 cookie 16 priority 2  tbl acl            in_pport 2 eth_type 0x08=
06 vlan_id 3841 ip proto 0/0 ip tos 0/0 group_id 0x0f010000
cmd 3 cookie 12 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.0=
 goto_tbl acl group_id 0x0f000000
cmd 3 cookie 9  priority 3  tbl acl            in_pport 1 01:80:c2:00:0=
0:00/ff:ff:ff:ff:ff:f0 eth_type 0x0000 vlan_id 3840 ip proto 0/0 ip tos=
 0/0 group_id 0x0f000000
cmd 3 cookie 6  priority 0  tbl term_mac       in_pport 2 eth_type 0x86=
dd 52:54:00:12:35:02 vlan_id 3841 goto_tbl ucast_routing copy_to_cpu 0
cmd 4 cookie 0  priority 1  tbl ig_port        in_pport 0/0xffff0000 go=
to_tbl vlan
cmd 4 cookie e  priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.3=
 goto_tbl acl group_id 0x0f000000
cmd 3 cookie 1  priority 1  tbl vlan           in_pport 1 vlan_id 0 got=
o_tbl term_mac untagged 1 new_vlan_id 3840
cmd 3 cookie 24 priority 20 tbl ucast_routing  eth_type 0x0800 11.0.0.4=
/255.255.255.252 goto_tbl acl group_id 0x20000000
cmd 4 cookie 14 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.1=
0 goto_tbl acl group_id 0x0f010000
cmd 3 cookie 2c priority 20 tbl ucast_routing  eth_type 0x0800 12.0.0.4=
 goto_tbl acl group_id 0x20000001
cmd 3 cookie 17 priority 1  tbl term_mac       in_pport 2 eth_type 0x08=
00 01:00:5e:00:00:00/ff:ff:ff:80:00:00 vlan_id 3841 goto_tbl mcast_rout=
ing copy_to_cpu 1
cmd 3 cookie 26 priority 20 tbl ucast_routing  eth_type 0x0800 12.0.0.3=
 goto_tbl acl group_id 0x20000000
cmd 3 cookie 2e priority 30 tbl ucast_routing  eth_type 0x0800 12.0.0.2=
 goto_tbl acl group_id 0x0f010000
cmd 3 cookie 22 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.9=
 goto_tbl acl group_id 0x20000001
cmd 3 cookie 1c priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.8=
/255.255.255.252 goto_tbl acl group_id 0x0f010000
cmd 3 cookie 18 priority 1  tbl term_mac       in_pport 2 eth_type 0x86=
dd 33:33:00:00:00:00/ff:ff:00:00:00:00 vlan_id 3841 goto_tbl mcast_rout=
ing copy_to_cpu 1
cmd 3 cookie 5  priority 0  tbl term_mac       in_pport 2 eth_type 0x08=
00 52:54:00:12:35:02 vlan_id 3841 goto_tbl ucast_routing copy_to_cpu 0
cmd 3 cookie a  priority 2  tbl acl            in_pport 1 eth_type 0x08=
06 vlan_id 3840 ip proto 0/0 ip tos 0/0 group_id 0x0f000000
cmd 4 cookie 1a priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.1=
1 goto_tbl acl group_id 0x0f010000
cmd 3 cookie 1e priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.8=
 goto_tbl acl group_id 0x0f010000
cmd 3 cookie 3  priority 0  tbl term_mac       in_pport 1 eth_type 0x86=
dd 52:54:00:12:35:01 vlan_id 3840 goto_tbl ucast_routing copy_to_cpu 0
cmd 3 cookie b  priority 1  tbl term_mac       in_pport 1 eth_type 0x08=
00 01:00:5e:00:00:00/ff:ff:ff:80:00:00 vlan_id 3840 goto_tbl mcast_rout=
ing copy_to_cpu 1
cmd 4 cookie 8  priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.2=
 goto_tbl acl group_id 0x0f000000
cmd 3 cookie 10 priority 0  tbl ucast_routing  eth_type 0x0800 11.0.0.0=
/255.255.255.252 goto_tbl acl group_id 0x0f000000
cmd 3 cookie 28 priority 20 tbl ucast_routing  eth_type 0x0800 11.0.0.1=
2/255.255.255.252 goto_tbl acl group_id 0x20000001
cmd 3 cookie c  priority 1  tbl term_mac       in_pport 1 eth_type 0x86=
dd 33:33:00:00:00:00/ff:ff:00:00:00:00 vlan_id 3840 goto_tbl mcast_rout=
ing copy_to_cpu 1

> cat /sys/kernel/debug/rocker/5254001235010000/of_dpa_group_tbl
cmd 7 group_id 0x0f000000 (L2 interface vlan 3840 port 0) pop_vlan 1
cmd 7 group_id 0x0f010000 (L2 interface vlan 3841 port 0) pop_vlan 1
cmd 7 group_id 0x20000000 (L3 unicast index 0) src 52:54:00:12:35:01 ds=
t 00:02:00:00:00:00 vlan 3840 ttl_check 1 group_id 0x0f000001
cmd 7 group_id 0x0f010002 (L2 interface vlan 3841 port 2) pop_vlan 1
cmd 7 group_id 0x0f000001 (L2 interface vlan 3840 port 1) pop_vlan 1
cmd 8 group_id 0x20000001 (L3 unicast index 1) src 52:54:00:12:35:02 ds=
t 00:02:00:00:01:00 vlan 3841 ttl_check 1 group_id 0x0f010002

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  359 ++++++++++++++++++++++++++=
++++++++
 drivers/net/ethernet/rocker/rocker.h |    2 +-
 2 files changed, 360 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/etherne=
t/rocker/rocker.c
index d963cdc..36e0891 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -18,6 +18,8 @@
 #include <linux/spinlock.h>
 #include <linux/hashtable.h>
 #include <linux/crc32.h>
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
 #include <linux/sort.h>
 #include <linux/random.h>
 #include <linux/netdevice.h>
@@ -43,6 +45,8 @@
=20
 static const char rocker_driver_name[] =3D "rocker";
=20
+static struct dentry *rocker_dbg_root;
+
 static const struct pci_device_id rocker_pci_id_table[] =3D {
 	{PCI_VDEVICE(REDHAT, PCI_DEVICE_ID_REDHAT_ROCKER), 0},
 	{0, }
@@ -238,6 +242,7 @@ struct rocker {
 	struct {
 		u64 id;
 	} hw;
+	struct dentry *dbg_dir;
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
@@ -2363,22 +2368,351 @@ static int rocker_cmd_group_tbl_del(const stru=
ct rocker_port *rocker_port,
  * Flow, group, FDB, internal VLAN and neigh tables
  ***************************************************/
=20
+static int dbg_of_dpa_flow_tbl_read(struct seq_file *file, void *data)
+{
+	struct rocker *rocker =3D file->private;
+	struct rocker_flow_tbl_entry *entry;
+	unsigned long flags;
+	int bkt;
+
+	char *tbl_id_to_str(enum rocker_of_dpa_table_id tbl_id)
+	{
+		switch (tbl_id) {
+		case ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT:
+			return "ig_port";
+		case ROCKER_OF_DPA_TABLE_ID_VLAN:
+			return "vlan";
+		case ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC:
+			return "term_mac";
+		case ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING:
+			return "ucast_routing";
+		case ROCKER_OF_DPA_TABLE_ID_MULTICAST_ROUTING:
+			return "mcast_routing";
+		case ROCKER_OF_DPA_TABLE_ID_BRIDGING:
+			return "bridge";
+		case ROCKER_OF_DPA_TABLE_ID_ACL_POLICY:
+			return "acl";
+		}
+		return "unknown";
+	}
+
+	spin_lock_irqsave(&rocker->flow_tbl_lock, flags);
+
+	hash_for_each(rocker->flow_tbl, bkt, entry, entry) {
+		struct rocker_flow_tbl_key *key =3D &entry->key;
+
+		seq_printf(file, "cmd %d cookie %llx\tpriority %-3d tbl %-15s",
+			   entry->cmd, entry->cookie,
+			   key->priority,
+			   tbl_id_to_str(key->tbl_id));
+		switch (key->tbl_id) {
+		case ROCKER_OF_DPA_TABLE_ID_INGRESS_PORT:
+			seq_printf(file, "in_pport %d",
+				   key->ig_port.in_pport);
+			if (key->ig_port.in_pport_mask !=3D 0xffffffff)
+				seq_printf(file, "/0x%08x",
+					   key->ig_port.in_pport_mask);
+			seq_printf(file, " goto_tbl %s\n",
+				   tbl_id_to_str(key->ig_port.goto_tbl));
+			break;
+		case ROCKER_OF_DPA_TABLE_ID_VLAN:
+			seq_printf(file, "in_pport %d vlan_id %d",
+				   key->vlan.in_pport,
+				   be16_to_cpu(key->vlan.vlan_id));
+			if (key->vlan.vlan_id_mask !=3D 0xffff)
+				seq_printf(file, "/0x%04x",
+					   be16_to_cpu(key->vlan.vlan_id_mask));
+			seq_printf(file, " goto_tbl %s untagged %d new_vlan_id %d\n",
+				   tbl_id_to_str(key->vlan.goto_tbl),
+				   key->vlan.untagged,
+				   be16_to_cpu(key->vlan.new_vlan_id));
+			break;
+		case ROCKER_OF_DPA_TABLE_ID_TERMINATION_MAC:
+			seq_printf(file, "in_pport %d",
+				   key->term_mac.in_pport);
+			if (key->term_mac.in_pport_mask !=3D 0xffffffff)
+				seq_printf(file, "/0x%08x",
+					   key->term_mac.in_pport_mask);
+			seq_printf(file, " eth_type 0x%04x %pM",
+				   be16_to_cpu(key->term_mac.eth_type),
+				   key->term_mac.eth_dst);
+			if (!is_broadcast_ether_addr(
+			    key->term_mac.eth_dst_mask))
+				seq_printf(file, "/%pM",
+					   key->term_mac.eth_dst_mask);
+			seq_printf(file, " vlan_id %d",
+				   be16_to_cpu(key->term_mac.vlan_id));
+			if (key->term_mac.vlan_id_mask !=3D 0xffff)
+				seq_printf(file, "/0x%04x",
+					   be16_to_cpu(
+					   key->term_mac.vlan_id_mask));
+			seq_printf(file, " goto_tbl %s copy_to_cpu %d\n",
+				   tbl_id_to_str(key->term_mac.goto_tbl),
+				   key->term_mac.copy_to_cpu);
+			break;
+		case ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING:
+			seq_printf(file, "eth_type 0x%04x %pI4",
+				   be16_to_cpu(key->ucast_routing.eth_type),
+				   &key->ucast_routing.dst4);
+			if (key->ucast_routing.dst4_mask !=3D 0xffffffff)
+				seq_printf(file, "/%pI4",
+					   &key->ucast_routing.dst4_mask);
+			seq_printf(file, " goto_tbl %s group_id 0x%08x\n",
+				   tbl_id_to_str(key->ucast_routing.goto_tbl),
+				   key->ucast_routing.group_id);
+			break;
+		case ROCKER_OF_DPA_TABLE_ID_BRIDGING:
+			if (key->bridge.has_eth_dst) {
+				seq_printf(file, "%pM",
+					   key->bridge.eth_dst);
+				if (key->bridge.has_eth_dst_mask)
+					seq_printf(file, "/%pM ",
+						   key->bridge.eth_dst_mask);
+				else
+					seq_puts(file, " ");
+			}
+			seq_printf(file, "vlan_id %d tunnel_id %d goto_tbl %s group_id 0x%0=
8x copy_to_cpu %d\n",
+				   be16_to_cpu(key->bridge.vlan_id),
+				   key->bridge.tunnel_id,
+				   tbl_id_to_str(key->bridge.goto_tbl),
+				   key->bridge.group_id,
+				   key->bridge.copy_to_cpu);
+			break;
+		case ROCKER_OF_DPA_TABLE_ID_ACL_POLICY:
+			seq_printf(file, "in_pport %d",
+				   key->acl.in_pport);
+			if (key->acl.in_pport_mask !=3D 0xffffffff)
+				seq_printf(file, "/0x%08x",
+					   key->acl.in_pport_mask);
+			if (!is_zero_ether_addr(key->acl.eth_src)) {
+				seq_printf(file, " %pM",
+					   key->acl.eth_src);
+				if (!is_broadcast_ether_addr(
+				    key->acl.eth_src_mask))
+					seq_printf(file, "/%pM",
+						   key->acl.eth_src_mask);
+			}
+			if (!is_zero_ether_addr(key->acl.eth_dst)) {
+				seq_printf(file, " %pM",
+					   key->acl.eth_dst);
+				if (!is_broadcast_ether_addr(
+				    key->acl.eth_dst_mask))
+					seq_printf(file, "/%pM",
+						   key->acl.eth_dst_mask);
+			}
+			seq_printf(file, " eth_type 0x%04x",
+				   be16_to_cpu(key->acl.eth_type));
+			seq_printf(file, " vlan_id %d",
+				   be16_to_cpu(key->acl.vlan_id));
+			if (key->acl.vlan_id_mask !=3D 0xffff)
+				seq_printf(file, "/0x%04x",
+					   be16_to_cpu(key->acl.vlan_id_mask));
+			seq_printf(file, " ip proto %d", key->acl.ip_proto);
+			if (key->acl.ip_proto_mask !=3D 0xff)
+				seq_printf(file, "/%d", key->acl.ip_proto_mask);
+			seq_printf(file, " ip tos %d", key->acl.ip_tos);
+			if (key->acl.ip_tos_mask !=3D 0xff)
+				seq_printf(file, "/%d", key->acl.ip_tos_mask);
+			seq_printf(file, " group_id 0x%08x\n",
+				   key->acl.group_id);
+			break;
+		default:
+			seq_puts(file, "\n");
+			break;
+		}
+	}
+
+	spin_unlock_irqrestore(&rocker->flow_tbl_lock, flags);
+
+	return 0;
+}
+
+static int dbg_of_dpa_group_tbl_read(struct seq_file *file, void *data=
)
+{
+	struct rocker *rocker =3D file->private;
+	struct rocker_group_tbl_entry *entry;
+	unsigned long flags;
+	u32 *group_id;
+	int bkt;
+	int i;
+
+	spin_lock_irqsave(&rocker->group_tbl_lock, flags);
+
+	hash_for_each(rocker->group_tbl, bkt, entry, entry) {
+		seq_printf(file, "cmd %d group_id 0x%08x",
+			   entry->cmd, entry->group_id);
+		switch (ROCKER_GROUP_TYPE_GET(entry->group_id)) {
+		case ROCKER_OF_DPA_GROUP_TYPE_L2_INTERFACE:
+			seq_printf(file, " (L2 interface vlan %d port %d)",
+				   ROCKER_GROUP_VLAN_GET(entry->group_id),
+				   ROCKER_GROUP_PORT_GET(entry->group_id));
+			seq_printf(file, " pop_vlan %d",
+				   entry->l2_interface.pop_vlan);
+			break;
+		case ROCKER_OF_DPA_GROUP_TYPE_L2_REWRITE:
+			seq_printf(file, " (L2 rewrite index %d)",
+				   ROCKER_GROUP_INDEX_LONG_GET(
+				   entry->group_id));
+			if (!is_zero_ether_addr(entry->l2_rewrite.eth_src))
+				seq_printf(file, " src %pM",
+					   entry->l2_rewrite.eth_src);
+			if (!is_zero_ether_addr(entry->l2_rewrite.eth_dst))
+				seq_printf(file, " dst %pM",
+					   entry->l2_rewrite.eth_dst);
+			if (entry->l2_rewrite.vlan_id)
+				seq_printf(file, " vlan %d",
+					   be16_to_cpu(
+					   entry->l2_rewrite.vlan_id));
+			seq_printf(file, " group_id 0x%08x",
+				   entry->l2_rewrite.group_id);
+			break;
+		case ROCKER_OF_DPA_GROUP_TYPE_L2_FLOOD:
+			seq_printf(file, " (L2 flood vlan %d index %d)",
+				   ROCKER_GROUP_VLAN_GET(entry->group_id),
+				   ROCKER_GROUP_INDEX_GET(entry->group_id));
+			break;
+		case ROCKER_OF_DPA_GROUP_TYPE_L2_MCAST:
+			seq_printf(file, " (L2 multicast vlan %d index %d)",
+				   ROCKER_GROUP_VLAN_GET(entry->group_id),
+				   ROCKER_GROUP_INDEX_GET(entry->group_id));
+			break;
+		case ROCKER_OF_DPA_GROUP_TYPE_L3_UCAST:
+			seq_printf(file, " (L3 unicast index %d)",
+				   ROCKER_GROUP_INDEX_LONG_GET(
+				   entry->group_id));
+			if (!is_zero_ether_addr(entry->l3_unicast.eth_src))
+				seq_printf(file, " src %pM",
+					   entry->l3_unicast.eth_src);
+			if (!is_zero_ether_addr(entry->l3_unicast.eth_dst))
+				seq_printf(file, " dst %pM",
+					   entry->l3_unicast.eth_dst);
+			if (entry->l3_unicast.vlan_id)
+				seq_printf(file, " vlan %d",
+					   be16_to_cpu(
+					   entry->l3_unicast.vlan_id));
+			seq_printf(file, " ttl_check %d",
+				   entry->l3_unicast.ttl_check);
+			seq_printf(file, " group_id 0x%08x",
+				   entry->l3_unicast.group_id);
+			break;
+		}
+		for (i =3D 0, group_id =3D entry->group_ids;
+		     i < entry->group_count;
+		     i++, group_id++)
+			seq_printf(file, "%s0x%08x%s",
+				   i =3D=3D 0 ? " {" : " ",
+				   *group_id,
+				   i + 1 =3D=3D entry->group_count ? "}" : "");
+		seq_puts(file, "\n");
+	}
+
+	spin_unlock_irqrestore(&rocker->group_tbl_lock, flags);
+
+	return 0;
+}
+
+static int dbg_fdb_tbl_read(struct seq_file *file, void *data)
+{
+	struct rocker *rocker =3D file->private;
+	struct rocker_fdb_tbl_entry *entry;
+	unsigned long flags;
+	int bkt;
+
+	spin_lock_irqsave(&rocker->fdb_tbl_lock, flags);
+
+	hash_for_each(rocker->fdb_tbl, bkt, entry, entry)
+		seq_printf(file, "learned %d pport %d addr %pM vlan %d\n",
+			   entry->learned, entry->key.pport,
+			   entry->key.addr, be16_to_cpu(entry->key.vlan_id));
+
+	spin_unlock_irqrestore(&rocker->fdb_tbl_lock, flags);
+
+	return 0;
+}
+
+static int dbg_internal_vlan_tbl_read(struct seq_file *file, void *dat=
a)
+{
+	struct rocker *rocker =3D file->private;
+	struct rocker_internal_vlan_tbl_entry *entry;
+	unsigned long flags;
+	int bkt;
+
+	spin_lock_irqsave(&rocker->internal_vlan_tbl_lock, flags);
+
+	hash_for_each(rocker->internal_vlan_tbl, bkt, entry, entry)
+		seq_printf(file, "ifindex %d ref_count %d vlan %d\n",
+			   entry->ifindex, entry->ref_count,
+			   be16_to_cpu(entry->vlan_id));
+
+	spin_unlock_irqrestore(&rocker->internal_vlan_tbl_lock, flags);
+
+	return 0;
+}
+
+static int dbg_neigh_tbl_read(struct seq_file *file, void *data)
+{
+	struct rocker *rocker =3D file->private;
+	struct rocker_neigh_tbl_entry *entry;
+	unsigned long flags;
+	int bkt;
+
+	spin_lock_irqsave(&rocker->neigh_tbl_lock, flags);
+
+	hash_for_each(rocker->neigh_tbl, bkt, entry, entry)
+		seq_printf(file, "%pI4 dev %s ref_count %d index %d dst %pM ttl_chec=
k %d\n",
+			   &entry->ip_addr, entry->dev->name, entry->ref_count,
+			   entry->index, entry->eth_dst, entry->ttl_check);
+
+	spin_unlock_irqrestore(&rocker->neigh_tbl_lock, flags);
+
+	return 0;
+}
+
+#define ROCKER_DBG_TBL(name) \
+	static int dbg_##name##_open(struct inode *inode, struct file *f) \
+	{                                                                 \
+		struct rocker *rocker =3D inode->i_private;                 \
+		return single_open(f, dbg_##name##_read, rocker);         \
+	}                                                                 \
+	static const struct file_operations dbg_##name##_ops =3D {          \
+		.owner =3D THIS_MODULE,                                     \
+		.open =3D dbg_##name##_open,                                \
+		.release =3D single_release,                                \
+		.read =3D seq_read,                                         \
+		.llseek =3D seq_lseek                                       \
+	}
+
+ROCKER_DBG_TBL(of_dpa_flow_tbl);
+ROCKER_DBG_TBL(of_dpa_group_tbl);
+ROCKER_DBG_TBL(fdb_tbl);
+ROCKER_DBG_TBL(internal_vlan_tbl);
+ROCKER_DBG_TBL(neigh_tbl);
+
 static int rocker_init_tbls(struct rocker *rocker)
 {
+#define ROCKER_CREATE_DBG_FILE(name)                                  =
    \
+	debugfs_create_file(#name, S_IRUGO, rocker->dbg_dir, rocker,      \
+			    &dbg_##name##_ops)
+
 	hash_init(rocker->flow_tbl);
 	spin_lock_init(&rocker->flow_tbl_lock);
+	ROCKER_CREATE_DBG_FILE(of_dpa_flow_tbl);
=20
 	hash_init(rocker->group_tbl);
 	spin_lock_init(&rocker->group_tbl_lock);
+	ROCKER_CREATE_DBG_FILE(of_dpa_group_tbl);
=20
 	hash_init(rocker->fdb_tbl);
 	spin_lock_init(&rocker->fdb_tbl_lock);
+	ROCKER_CREATE_DBG_FILE(fdb_tbl);
=20
 	hash_init(rocker->internal_vlan_tbl);
 	spin_lock_init(&rocker->internal_vlan_tbl_lock);
+	ROCKER_CREATE_DBG_FILE(internal_vlan_tbl);
=20
 	hash_init(rocker->neigh_tbl);
 	spin_lock_init(&rocker->neigh_tbl_lock);
+	ROCKER_CREATE_DBG_FILE(neigh_tbl);
=20
 	return 0;
 }
@@ -5092,6 +5426,7 @@ static void rocker_msix_fini(const struct rocker =
*rocker)
 static int rocker_probe(struct pci_dev *pdev, const struct pci_device_=
id *id)
 {
 	struct rocker *rocker;
+	char dbg_dir_name[sizeof(rocker->hw.id) * 2 + 1];
 	int err;
=20
 	rocker =3D kzalloc(sizeof(*rocker), GFP_KERNEL);
@@ -5180,6 +5515,13 @@ static int rocker_probe(struct pci_dev *pdev, co=
nst struct pci_device_id *id)
 	}
=20
 	rocker->hw.id =3D rocker_read64(rocker, SWITCH_ID);
+	sprintf(dbg_dir_name, "%*phN", (int)sizeof(rocker->hw.id),
+		&rocker->hw.id);
+	rocker->dbg_dir =3D debugfs_create_dir(dbg_dir_name, rocker_dbg_root)=
;
+	if (!rocker->dbg_dir) {
+		err =3D -ENOMEM;
+		goto err_dbg_dir;
+	}
=20
 	err =3D rocker_init_tbls(rocker);
 	if (err) {
@@ -5201,6 +5543,8 @@ static int rocker_probe(struct pci_dev *pdev, con=
st struct pci_device_id *id)
 err_probe_ports:
 	rocker_free_tbls(rocker);
 err_init_tbls:
+	debugfs_remove_recursive(rocker->dbg_dir);
+err_dbg_dir:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
 err_request_event_irq:
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_CMD), rocker);
@@ -5227,6 +5571,7 @@ static void rocker_remove(struct pci_dev *pdev)
 	struct rocker *rocker =3D pci_get_drvdata(pdev);
=20
 	rocker_free_tbls(rocker);
+	debugfs_remove_recursive(rocker->dbg_dir);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	rocker_remove_ports(rocker);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
@@ -5425,18 +5770,31 @@ static struct notifier_block rocker_netevent_nb=
 __read_mostly =3D {
  * Module init and exit
  ***********************/
=20
+static int rocker_debugfs_init(void)
+{
+	rocker_dbg_root =3D debugfs_create_dir(rocker_driver_name, NULL);
+	if (!rocker_dbg_root)
+		return -ENOMEM;
+	return 0;
+}
+
 static int __init rocker_module_init(void)
 {
 	int err;
=20
 	register_netdevice_notifier(&rocker_netdevice_nb);
 	register_netevent_notifier(&rocker_netevent_nb);
+	err =3D rocker_debugfs_init();
+	if (err)
+		goto err_debugfs;
 	err =3D pci_register_driver(&rocker_pci_driver);
 	if (err)
 		goto err_pci_register_driver;
 	return 0;
=20
 err_pci_register_driver:
+	debugfs_remove_recursive(rocker_dbg_root);
+err_debugfs:
 	unregister_netevent_notifier(&rocker_netevent_nb);
 	unregister_netdevice_notifier(&rocker_netdevice_nb);
 	return err;
@@ -5444,6 +5802,7 @@ err_pci_register_driver:
=20
 static void __exit rocker_module_exit(void)
 {
+	debugfs_remove_recursive(rocker_dbg_root);
 	unregister_netevent_notifier(&rocker_netevent_nb);
 	unregister_netdevice_notifier(&rocker_netdevice_nb);
 	pci_unregister_driver(&rocker_pci_driver);
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/etherne=
t/rocker/rocker.h
index 12490b2..0eacc53 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -419,7 +419,7 @@ enum rocker_of_dpa_overlay_type {
 #define ROCKER_GROUP_TYPE_SET(type) \
 	(((type) << ROCKER_GROUP_TYPE_SHIFT) & ROCKER_GROUP_TYPE_MASK)
 #define ROCKER_GROUP_VLAN_GET(group_id) \
-	(((group_id) & ROCKER_GROUP_VLAN_ID_MASK) >> ROCKER_GROUP_VLAN_ID_SHI=
=46T)
+	(((group_id) & ROCKER_GROUP_VLAN_MASK) >> ROCKER_GROUP_VLAN_SHIFT)
 #define ROCKER_GROUP_VLAN_SET(vlan_id) \
 	(((vlan_id) << ROCKER_GROUP_VLAN_SHIFT) & ROCKER_GROUP_VLAN_MASK)
 #define ROCKER_GROUP_PORT_GET(group_id) \
--=20
1.7.10.4
