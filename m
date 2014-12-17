From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] Documentation: clarify phys_port_id
Date: Wed, 17 Dec 2014 10:59:36 -0600
Message-ID: <1418835576.1160.38.camel@dcbw.local>
References: <CAEPrYjTZ8SU1y4TwKHYtZju+4_-O5mazAjaFKaKmR2cYuAKHnA@mail.gmail.com>
	 <1418834826.1160.35.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joshua Watt <jpewdev@gmail.com>, jpirko@redhat.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33541 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbaLQQ7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 11:59:40 -0500
In-Reply-To: <1418834826.1160.35.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
 Documentation/ABI/testing/sysfs-class-net | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net b/Documentation/ABI/testing/sysfs-class-net
index e1b2e78..7fe823a 100644
--- a/Documentation/ABI/testing/sysfs-class-net
+++ b/Documentation/ABI/testing/sysfs-class-net
@@ -186,7 +186,12 @@ KernelVersion:	3.12
 Contact:	netdev@vger.kernel.org
 Description:
 		Indicates the interface unique physical port identifier within
-		the NIC, as a string.
+		the NIC, as a string.  If two net_device objects share physical
+		hardware or other resources, and/or do not operate independently
+		both net_device objects should be assigned the
+		same phys_port_id.  phys_port_id should be as globally unique
+		as possible to prevent conflicts between different drivers and
+		vendors, eg with MAC addresses or hardware GUIDs.
 
 What:		/sys/class/net/<iface>/speed
 Date:		October 2009
-- 
1.9.3
