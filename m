From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 10/27] drivers/net/enic: fix sparse warning: make symbol static
Date: Mon, 22 Dec 2008 20:16:23 +0100
Message-ID: <20081222191622.11807.9132.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212AbYLVTQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:16:28 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warning:

  drivers/net/enic/vnic_dev.c:288:5: warning: symbol 'vnic_dev_capable' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/enic/vnic_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 08a37b0..1170857 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -285,7 +285,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	return -ETIMEDOUT;
 }
 
-int vnic_dev_capable(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd)
+static int vnic_dev_capable(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd)
 {
 	u64 a0 = (u32)cmd, a1 = 0;
 	int wait = 1000;

