From: Dave Jones <davej@redhat.com>
Subject: [4/4] Fix typos in comments in via-velocity header.
Date: Mon, 20 Jul 2009 23:40:48 -0400
Message-ID: <200907211640.n6LGeHPx011459@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52611 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755760AbZGUQkS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 12:40:18 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeJxS001595
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:19 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n6LGeINj025779
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:18 -0400
Received: from gelk.kernelslacker.org (vpn-10-139.bos.redhat.com [10.16.10.139])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n6LGeHPb015098
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Received: from gelk.kernelslacker.org (gelk.kernelslacker.org [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id n6LGeHwQ011460
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:40:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dave Jones <davej@redhat.com>
---
 drivers/net/via-velocity.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 4cd3f6c..2f00c13 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -96,8 +96,8 @@
  * Bits in the CSM register
  */
 
-#define CSM_IPOK            0x40	//IP Checkusm validatiaon ok
-#define CSM_TUPOK           0x20	//TCP/UDP Checkusm validatiaon ok
+#define CSM_IPOK            0x40	//IP Checksum validation ok
+#define CSM_TUPOK           0x20	//TCP/UDP Checksum validation ok
 #define CSM_FRAG            0x10	//Fragment IP datagram
 #define CSM_IPKT            0x04	//Received an IP packet
 #define CSM_TCPKT           0x02	//Received a TCP packet
@@ -819,7 +819,7 @@ enum  velocity_owner {
  *	Bits in the EECSR register
  */
 
-#define EECSR_EMBP          0x40	/* eeprom embeded programming */
+#define EECSR_EMBP          0x40	/* eeprom embedded programming */
 #define EECSR_RELOAD        0x20	/* eeprom content reload */
 #define EECSR_DPM           0x10	/* eeprom direct programming */
 #define EECSR_ECS           0x08	/* eeprom CS pin */
-- 
1.6.2.5

