From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: Cleanup incorrect header comments
Date: Fri, 12 Feb 2010 15:48:44 -0800
Message-ID: <20100212234843.2346.93249.stgit@localhost.localdomain>
References: <20100212234715.2346.60380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:48683
	"EHLO qmta11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754057Ab0BLXtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 18:49:11 -0500
In-Reply-To: <20100212234715.2346.60380.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The recent n-tuple patches added some comments to the headers
of the Flow Director functions that aren't accurate.  This
cleans them up, and is a purely cosmetic patch.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 4fa8633..1f30e16 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1631,7 +1631,6 @@ static u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input,
  *  ixgbe_atr_set_vlan_id_82599 - Sets the VLAN id in the ATR input stream
  *  @input: input stream to modify
  *  @vlan: the VLAN id to load
- *  @vlan_mask: bitwise mask for the VLAN
  **/
 s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
 {
@@ -1645,7 +1644,6 @@ s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
  *  ixgbe_atr_set_src_ipv4_82599 - Sets the source IPv4 address
  *  @input: input stream to modify
  *  @src_addr: the IP address to load
- *  @src_addr_mask: bitwise mask for the source IP address
  **/
 s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
 {
@@ -1663,7 +1661,6 @@ s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
  *  ixgbe_atr_set_dst_ipv4_82599 - Sets the destination IPv4 address
  *  @input: input stream to modify
  *  @dst_addr: the IP address to load
- *  @dst_addr_mask: bitwise mask for the destination IP address
  **/
 s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
 {
@@ -1767,7 +1764,6 @@ s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
  *  ixgbe_atr_set_src_port_82599 - Sets the source port
  *  @input: input stream to modify
  *  @src_port: the source port to load
- *  @src_port_mask: bitwise mask for the source port
  **/
 s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
 {
@@ -1781,7 +1777,6 @@ s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
  *  ixgbe_atr_set_dst_port_82599 - Sets the destination port
  *  @input: input stream to modify
  *  @dst_port: the destination port to load
- *  @dst_port_mask: bitwise mask for the destination port
  **/
 s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input, u16 dst_port)
 {

