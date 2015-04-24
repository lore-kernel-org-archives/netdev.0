From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 11/15] flow_dissector: add missing header includes
Date: Fri, 24 Apr 2015 17:51:37 +0200
Message-ID: <1429890701-30052-12-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33014 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031216AbbDXPwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:52:03 -0400
Received: by wgin8 with SMTP id n8so55196778wgi.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:52:02 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 32a7997..b67ce84 100644
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
