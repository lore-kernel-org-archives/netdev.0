From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH] vxge/s2io: remove dead URLs
Date: Mon,  9 Jul 2012 17:07:57 -0700
Message-ID: <1341878877-10507-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53357 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755034Ab2GJAHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 20:07:25 -0400
Received: by pbbrp8 with SMTP id rp8so20016740pbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 17:07:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

URLs to neterion.com and s2io.com no longer resolve.  Remove all references to
these URLs in the driver source and documentation.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 Documentation/networking/s2io.txt              |   14 ++------------
 Documentation/networking/vxge.txt              |    7 -------
 MAINTAINERS                                    |    2 --
 drivers/net/ethernet/neterion/vxge/vxge-main.c |    4 +---
 4 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/Documentation/networking/s2io.txt b/Documentation/networking/s2io.txt
index 4be0c03..6b5cbfa 100644
--- a/Documentation/networking/s2io.txt
+++ b/Documentation/networking/s2io.txt
@@ -136,16 +136,6 @@ For more information, please review the AMD8131 errata at
 http://vip.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/
 26310_AMD-8131_HyperTransport_PCI-X_Tunnel_Revision_Guide_rev_3_18.pdf
 
-6.  Available Downloads
-Neterion "s2io" driver in Red Hat and Suse 2.6-based distributions is kept up 
-to date, also the latest "s2io" code (including support for 2.4 kernels) is 
-available via "Support" link on the Neterion site:  http://www.neterion.com.
-
-For Xframe User Guide (Programming manual), visit ftp site ns1.s2io.com,
-user: linuxdocs password: HALdocs
-
-7. Support 
+6. Support 
 For further support please contact either your 10GbE Xframe NIC vendor (IBM, 
-HP, SGI etc.) or click on the "Support" link on the Neterion site:  
-http://www.neterion.com.
-
+HP, SGI etc.)
diff --git a/Documentation/networking/vxge.txt b/Documentation/networking/vxge.txt
index d2e2997..bb76c66 100644
--- a/Documentation/networking/vxge.txt
+++ b/Documentation/networking/vxge.txt
@@ -91,10 +91,3 @@ v)  addr_learn_en
        virtualization environment.
        Valid range: 0,1 (disabled, enabled respectively)
        Default: 0
-
-4) Troubleshooting:
--------------------
-
-To resolve an issue with the source code or X3100 series adapter, please collect
-the statistics, register dumps using ethool, relevant logs and email them to
-support@neterion.com.
diff --git a/MAINTAINERS b/MAINTAINERS
index 8da1373..ce7398e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4638,8 +4638,6 @@ F:	net/sched/sch_netem.c
 NETERION 10GbE DRIVERS (s2io/vxge)
 M:	Jon Mason <jdmason@kudzu.us>
 L:	netdev@vger.kernel.org
-W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/Linux?Anonymous
-W:	http://trac.neterion.com/cgi-bin/trac.cgi/wiki/X3100Linux?Anonymous
 S:	Supported
 F:	Documentation/networking/s2io.txt
 F:	Documentation/networking/vxge.txt
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-main.c b/drivers/net/ethernet/neterion/vxge/vxge-main.c
index 2fd1edb..24824fcc 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-main.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-main.c
@@ -4261,9 +4261,7 @@ static int vxge_probe_fw_update(struct vxgedev *vdev)
 	if (VXGE_FW_VER(VXGE_CERT_FW_VER_MAJOR, VXGE_CERT_FW_VER_MINOR, 0) >
 	    VXGE_FW_VER(maj, min, 0)) {
 		vxge_debug_init(VXGE_ERR, "%s: Firmware %d.%d.%d is too old to"
-				" be used with this driver.\n"
-				"Please get the latest version from "
-				"ftp://ftp.s2io.com/pub/X3100-Drivers/FIRMWARE",
+				" be used with this driver."
 				VXGE_DRIVER_NAME, maj, min, bld);
 		return -EINVAL;
 	}
-- 
1.7.9.5
