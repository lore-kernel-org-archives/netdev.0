From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v4 4/5] bridge: add json schema for bridge fdb show
Date: Wed, 22 Jun 2016 06:45:54 -0700
Message-ID: <1466603155-53768-5-git-send-email-roopa@cumulusnetworks.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34851 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbcFVNyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 09:54:40 -0400
Received: by mail-pa0-f42.google.com with SMTP id hl6so17210954pac.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 06:53:49 -0700 (PDT)
In-Reply-To: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Storing the schema file for the json format will be useful for doc
purposes as optional paramaters are typically suppressed in the json
sample outputs.

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
---
 schema/bridge_fdb_schema.json | 62 +++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 62 insertions(+)
 create mode 100644 schema/bridge_fdb_schema.json

diff --git a/schema/bridge_fdb_schema.json b/schema/bridge_fdb_schema.json
new file mode 100644
index 0000000..3e5be8d
--- /dev/null
+++ b/schema/bridge_fdb_schema.json
@@ -0,0 +1,62 @@
+{
+    "$schema": "http://json-schema.org/draft-04/schema#",
+    "description": "bridge fdb show",
+    "type": "array",
+    "items": {
+        "type": "object",
+        "properties": {
+            "dev": {
+                "type": "string"
+            },
+            "dst": {
+                "description" : "host name or ip address",
+                "type": "string"
+            },
+            "flags": {
+                "type": "array",
+                "items": {
+                    "enum": ["self", "master", "router", "offload"]
+                },
+                "uniqueItems": true
+            },
+            "linkNetNsId": {
+                "type": "integer"
+            },
+            "mac": {
+                "type": "string"
+            },
+            "master": {
+                "type": "string"
+            },
+            "opCode": {
+                "description" : "used to indicate fdb entry del",
+                "enum": ["deleted"]
+            },
+            "port": {
+                "type": "integer"
+            },
+            "state": {
+                "description" : "permanent, static, stale, state=#x",
+                "type": "string"
+            },
+            "updated": {
+                "type": "integer"
+            },
+            "used": {
+                "type": "integer"
+            },
+            "viaIf": {
+                "type": "string"
+            },
+            "viaIfIndex": {
+                "type": "integer"
+            },
+            "vlan": {
+                "type": "integer"
+            },
+            "vni": {
+                "type": "integer"
+            }
+        }
+    }
+}
-- 
1.9.1
