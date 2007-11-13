From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/25] NFS: Increase size of cl_ipaddr field to hold IPv6
	addresses
Date: Tue, 13 Nov 2007 13:31:16 -0500
Message-ID: <20071113183116.5087.21901.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:10497 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759326AbXKMScl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 13:32:41 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nfs_client's cl_ipaddr field needs to be larger to hold strings that
represent IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 include/linux/nfs_fs_sb.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 8a3061c..f2a0f20 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -63,7 +63,7 @@ struct nfs_client {
 	/* Our own IP address, as a null-terminated string.
 	 * This is used to generate the clientid, and the callback address.
 	 */
-	char			cl_ipaddr[16];
+	char			cl_ipaddr[64];
 	unsigned char		cl_id_uniquifier;
 #endif
 };

