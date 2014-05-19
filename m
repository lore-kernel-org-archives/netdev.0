From: =?UTF-8?q?Toralf=20F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: [PATCH] fix format mismatch in drivers/net/ethernet/intel/i40e/i40e_debugfs.c
Date: Mon, 19 May 2014 14:04:50 +0200
Message-ID: <1400501090-315-1-git-send-email-toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	=?UTF-8?q?Toralf=20F=C3=B6rster?= <toralf.foerster@gmx.de>
To: shannon.nelson@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:53322 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758AbaESME4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2014 08:04:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spotted by cppcheck

Signed-off-by: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/n=
et/ethernet/intel/i40e/i40e_debugfs.c
index 3c37386..1bc35a2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1239,7 +1239,7 @@ static ssize_t i40e_dbg_command_write(struct file=
 *filp,
 	} else if (strncmp(cmd_buf, "add pvid", 8) =3D=3D 0) {
 		i40e_status ret;
 		u16 vid;
-		int v;
+		unsigned int v;
=20
 		cnt =3D sscanf(&cmd_buf[8], "%i %u", &vsi_seid, &v);
 		if (cnt !=3D 2) {
@@ -1255,7 +1255,7 @@ static ssize_t i40e_dbg_command_write(struct file=
 *filp,
 			goto command_write_done;
 		}
=20
-		vid =3D (unsigned)v;
+		vid =3D v;
 		ret =3D i40e_vsi_add_pvid(vsi, vid);
 		if (!ret)
 			dev_info(&pf->pdev->dev,
--=20
1.9.3
