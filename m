From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 4/5] bridge: add json schema for bridge fdb show
Date: Fri, 27 May 2016 21:37:15 -0700
Message-ID: <1464410236-65044-5-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34484 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbcE1Eha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2016 00:37:30 -0400
Received: by mail-pa0-f52.google.com with SMTP id bz2so16048314pad.1
        for <netdev@vger.kernel.org>; Fri, 27 May 2016 21:37:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

we think storing the schema file for the json
format will be useful.

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
