From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 11/15] flow_dissector: add missing header includes
Date: Tue, 12 May 2015 14:56:17 +0200
Message-ID: <1431435381-7164-12-git-send-email-jiri@resnulli.us>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:38203 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932992AbbELM5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:57:19 -0400
Received: by wicnf17 with SMTP id nf17so14253933wic.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 05:57:18 -0700 (PDT)
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
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
2.4.0
