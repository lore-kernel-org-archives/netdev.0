From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e: fix format mismatch in drivers/net/ethernet/intel/i40e/i40e_debugfs.c
Date: Thu, 24 Jul 2014 06:13:17 -0700
Message-ID: <1406207604-31653-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Toralf=20F=C3=B6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36520 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759148AbaGXNOF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:05 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Toralf F=C3=B6rster <toralf.foerster@gmx.de>

spotted by cppcheck

Signed-off-by: Toralf F=C3=B6rster <toralf.foerster@gmx.de>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/n=
et/ethernet/intel/i40e/i40e_debugfs.c
index ec07332..9eaed04 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1238,7 +1238,7 @@ static ssize_t i40e_dbg_command_write(struct file=
 *filp,
 	} else if (strncmp(cmd_buf, "add pvid", 8) =3D=3D 0) {
 		i40e_status ret;
 		u16 vid;
-		int v;
+		unsigned int v;
=20
 		cnt =3D sscanf(&cmd_buf[8], "%i %u", &vsi_seid, &v);
 		if (cnt !=3D 2) {
@@ -1254,7 +1254,7 @@ static ssize_t i40e_dbg_command_write(struct file=
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
