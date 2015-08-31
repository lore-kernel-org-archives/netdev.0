From: Philip Downey <pdowney@brocade.com>
Subject: [PATCH 2/2] IGMP: Inhibit reports for local multicast groups - DOCUMENT
Date: Mon, 31 Aug 2015 11:30:38 +0100
Message-ID: <dff26e321e8af946d1dd1899eef1327e64a517a3.1441016151.git.pdowney@brocade.com>
References: <d208b6d6990faa29d022fbdc03bd9968a458e250.1441016151.git.pdowney@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Philip Downey <pdowney@brocade.com>
To: <cwang@twopensource.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d208b6d6990faa29d022fbdc03bd9968a458e250.1441016151.git.pdowney@brocade.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Document the addition of a new sysctl variable which controls the
generation of IGMP reports for link local multicast groups in the
224.0.0.X range.

IGMP reports for local multicast groups can now be optionally
inhibited by setting the value to zero e.g.:
echo 0 > /proc/sys/net/ipv4/igmp_link_local_mcast_reports

To retain backwards compatibility the previous behaviour is retained
by default on system boot or reverted by setting the value back to
non-zero.

Signed-off-by: Philip Downey <pdowney@brocade.com>
---
 Documentation/networking/ip-sysctl.txt |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 5fae770..5f394d5 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1181,6 +1181,11 @@ tag - INTEGER
 	Allows you to write a number, which can be used as required.
 	Default value is 0.
 
+igmp_link_local_mcast_reports - BOOLEAN
+	Enable IGMP reports for link local multicast groups in the
+	224.0.0.X range.
+	Default TRUE
+
 Alexey Kuznetsov.
 kuznet@ms2.inr.ac.ru
 
-- 
1.7.10.4
