From: Ferenc Wagner <wferi@niif.hu>
Subject: [PATCH] vlan: Fix typos in proc output string
Date: Thu, 06 Nov 2008 12:18:27 +0100
Message-ID: <877i7hyuf0.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:51201 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753326AbYKFLSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2008 06:18:30 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.63)
	(envelope-from <wferi@niif.hu>)
	id 1Ky2sd-0007DJ-9J
	for netdev@vger.kernel.org; Thu, 06 Nov 2008 12:18:27 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ferenc Wagner <wferi@niif.hu>
---
 net/8021q/vlanproc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 0feefa4..3628e0a 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -314,7 +314,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 		   dev_info->ingress_priority_map[6],
 		   dev_info->ingress_priority_map[7]);
 
-	seq_printf(seq, "EGRESSS priority Mappings: ");
+	seq_printf(seq, " EGRESS priority mappings: ");
 	for (i = 0; i < 16; i++) {
 		const struct vlan_priority_tci_mapping *mp
 			= dev_info->egress_priority_map[i];
-- 
1.5.6.5
