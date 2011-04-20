From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] net:bna: fix compile warning of =?UTF-8?B?4oCYYmZhX2lvY18=?=
 =?UTF-8?B?c21lbV9wZ29mZuKAmSBkZWZpbmVkIGJ1dCBub3QgdXNlZA==?=
Date: Wed, 20 Apr 2011 09:38:06 +0800
Message-ID: <4DAE38FE.1010503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53185 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751340Ab1DTBl6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 21:41:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix the below compile warning:

drivers/net/bna/bfa_ioc.c:1922: warning: =E2=80=98bfa_ioc_smem_pgoff=E2=
=80=99 defined but not used


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/bna/bfa_ioc.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index ba2a4e1..fcb9bb3 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -82,7 +82,6 @@ static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc=
);
 static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
 			 u32 boot_param);
 static u32 bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr);
-static u32 bfa_ioc_smem_pgoff(struct bfa_ioc *ioc, u32 fmaddr);
 static void bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc,
 						char *serial_num);
 static void bfa_ioc_get_adapter_fw_ver(struct bfa_ioc *ioc,
@@ -1923,12 +1922,6 @@ bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmad=
dr)
 	return PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, fmaddr);
 }
=20
-static u32
-bfa_ioc_smem_pgoff(struct bfa_ioc *ioc, u32 fmaddr)
-{
-	return PSS_SMEM_PGOFF(fmaddr);
-}
-
 /**
  * Register mailbox message handler function, to be called by common m=
odules
  */
--=20
1.6.3.3
