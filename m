From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/5] igb: Add comment
Date: Thu, 01 Jul 2010 16:39:23 -0700
Message-ID: <20100701233921.16171.58140.stgit@localhost.localdomain>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:38482 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754435Ab0GAXjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:39:42 -0400
In-Reply-To: <20100701233733.16171.4629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add explanatory comment to avoid confusion when a pointer is set
to the second word of an array instead of the customary cast of a
pointer to the beginning of the array.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d811462..9cb04e2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4974,6 +4974,10 @@ static void igb_vf_reset_msg(struct igb_adapter *adapter, u32 vf)
 
 static int igb_set_vf_mac_addr(struct igb_adapter *adapter, u32 *msg, int vf)
 {
+	/*
+	 * The VF MAC Address is stored in a packed array of bytes
+	 * starting at the second 32 bit word of the msg array
+	 */
 	unsigned char *addr = (char *)&msg[1];
 	int err = -1;
 

