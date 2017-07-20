From: Rob Herring <robh@kernel.org>
Subject: [PATCH 2/2] of: remove unused struct device_node.data ptr
Date: Thu, 20 Jul 2017 09:27:11 -0500
Message-ID: <20170720142711.12847-2-robh@kernel.org>
References: <20170720142711.12847-1-robh@kernel.org>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Frank Rowand <frowand.list@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33886 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755101AbdGTO1S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 10:27:18 -0400
In-Reply-To: <20170720142711.12847-1-robh@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are no users for data pointer in the kernel, so it can be removed.

Signed-off-by: Rob Herring <robh@kernel.org>
---
 include/linux/of.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/linux/of.h b/include/linux/of.h
index 4a8a70916237..7312c8ac5221 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -60,7 +60,6 @@ struct device_node {
 	struct	device_node *sibling;
 	struct	kobject kobj;
 	unsigned long _flags;
-	void	*data;
 #if defined(CONFIG_SPARC)
 	const char *path_component_name;
 	unsigned int unique_id;
-- 
2.11.0
