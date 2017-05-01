From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] xdp: fix parameter kdoc for extack
Date: Mon,  1 May 2017 15:53:43 -0700
Message-ID: <20170501225343.22157-1-jakub.kicinski@netronome.com>
References: <201705020535.2FQBLyjE%fengguang.wu@intel.com>
Cc: kbuild-all@01.org, fengguang.wu@intel.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33280 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdEAWyX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 18:54:23 -0400
Received: by mail-pf0-f173.google.com with SMTP id q20so26508742pfg.0
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 15:54:23 -0700 (PDT)
In-Reply-To: <201705020535.2FQBLyjE%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix kdoc parameter spelling from extact to extack.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 35a06cebb282..0b2876e00834 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6854,7 +6854,7 @@ EXPORT_SYMBOL(dev_change_proto_down);
 /**
  *	dev_change_xdp_fd - set or clear a bpf program for a device rx path
  *	@dev: device
- *	@extact: netlink extended ack
+ *	@extack: netlink extended ack
  *	@fd: new program fd or negative value to clear
  *	@flags: xdp-related flags
  *
-- 
2.11.0
