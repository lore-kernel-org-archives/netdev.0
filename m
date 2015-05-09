From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/15] flow_dissector: add missing header includes
Date: Sat,  9 May 2015 15:10:34 +0200
Message-ID: <1431177038-11555-12-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33244 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751626AbbEINL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:11:26 -0400
Received: by wgin8 with SMTP id n8so93460151wgi.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:11:25 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
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
