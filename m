From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next 2/3] samples/bpf: add static to function with no prototype
Date: Mon, 24 Apr 2017 15:31:07 +0200
Message-ID: <20170424133108.31595-3-alexander@alemayhu.com>
References: <20170424133108.31595-1-alexander@alemayhu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Alexander Alemayhu <alexander@alemayhu.com>, daniel@iogearbox.net,
        ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:34403 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1171285AbdDXNbV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 09:31:21 -0400
Received: by mail-lf0-f47.google.com with SMTP id t144so73924997lff.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 06:31:20 -0700 (PDT)
In-Reply-To: <20170424133108.31595-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes the following warning

samples/bpf/cookie_uid_helper_example.c: At top level:
samples/bpf/cookie_uid_helper_example.c:276:6: warning: no previous prototype for ‘finish’ [-Wmissing-prototypes]
 void finish(int ret)
      ^~~~~~
  HOSTLD  samples/bpf/per_socket_stats_example

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 samples/bpf/cookie_uid_helper_example.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/samples/bpf/cookie_uid_helper_example.c b/samples/bpf/cookie_uid_helper_example.c
index ad5afedf2e70..9ce55840d61d 100644
--- a/samples/bpf/cookie_uid_helper_example.c
+++ b/samples/bpf/cookie_uid_helper_example.c
@@ -273,7 +273,7 @@ static int usage(void)
 	return 1;
 }
 
-void finish(int ret)
+static void finish(int ret)
 {
 	test_finish = true;
 }
-- 
2.9.3
