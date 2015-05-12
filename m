From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 11/15] flow_dissector: add missing header includes
Date: Tue, 12 May 2015 09:39:19 +0200
Message-ID: <1431416363-5675-12-git-send-email-jiri@resnulli.us>
References: <1431416363-5675-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36406 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066AbbELHkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 03:40:14 -0400
Received: by wizk4 with SMTP id k4so139654064wiz.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 00:40:13 -0700 (PDT)
In-Reply-To: <1431416363-5675-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 0c8d406..1add891 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -1,6 +1,9 @@
 #ifndef _NET_FLOW_DISSECTOR_H
 #define _NET_FLOW_DISSECTOR_H
 
+#include <linux/types.h>
+#include <linux/skbuff.h>
+
 /**
  * struct flow_dissector_key_basic:
  * @thoff: Transport header offset
-- 
1.9.3
