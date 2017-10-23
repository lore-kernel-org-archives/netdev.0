From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/12] tools: bpftool: add cosmetic changes for the manual pages
Date: Mon, 23 Oct 2017 09:24:15 -0700
Message-ID: <20171023162416.32753-12-jakub.kicinski@netronome.com>
References: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:46811 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdJWQZF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 12:25:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id k7so12171591pga.3
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 09:25:05 -0700 (PDT)
In-Reply-To: <20171023162416.32753-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Make the look-and-feel of the manual pages somewhat closer to other
manual pages, such as the ones from the utilities from iproute2, by
highlighting more keywords.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/Documentation/bpftool-map.rst  | 25 ++++++++++++------------
 tools/bpf/bpftool/Documentation/bpftool-prog.rst | 12 ++++++------
 tools/bpf/bpftool/Documentation/bpftool.rst      | 12 +++++++-----
 3 files changed, 26 insertions(+), 23 deletions(-)

diff --git a/tools/bpf/bpftool/Documentation/bpftool-map.rst b/tools/bpf/bpftool/Documentation/bpftool-map.rst
index 5210c4fab356..3954b3ea4f26 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-map.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-map.rst
@@ -13,23 +13,24 @@ SYNOPSIS
 	**bpftool** **map** *COMMAND*
 
 	*COMMANDS* :=
-	{ show | dump | update | lookup | getnext | delete | pin | help }
+	{ **show** | **dump** | **update** | **lookup** | **getnext** | **delete**
+	| **pin** | **help** }
 
 MAP COMMANDS
 =============
 
-|	**bpftool** map show   [*MAP*]
-|	**bpftool** map dump    *MAP*
-|	**bpftool** map update  *MAP*  key *BYTES*   value *VALUE* [*UPDATE_FLAGS*]
-|	**bpftool** map lookup  *MAP*  key *BYTES*
-|	**bpftool** map getnext *MAP* [key *BYTES*]
-|	**bpftool** map delete  *MAP*  key *BYTES*
-|	**bpftool** map pin     *MAP*  *FILE*
-|	**bpftool** map help
+|	**bpftool** **map show**   [*MAP*]
+|	**bpftool** **map dump**    *MAP*
+|	**bpftool** **map update**  *MAP*  **key** *BYTES*   **value** *VALUE* [*UPDATE_FLAGS*]
+|	**bpftool** **map lookup**  *MAP*  **key** *BYTES*
+|	**bpftool** **map getnext** *MAP* [**key** *BYTES*]
+|	**bpftool** **map delete**  *MAP*  **key** *BYTES*
+|	**bpftool** **map pin**     *MAP*  *FILE*
+|	**bpftool** **map help**
 |
-|	*MAP* := { id MAP_ID | pinned FILE }
-|	*VALUE* := { BYTES | MAP | PROGRAM }
-|	*UPDATE_FLAGS* := { any | exist | noexist }
+|	*MAP* := { **id** *MAP_ID* | **pinned** *FILE* }
+|	*VALUE* := { *BYTES* | *MAP* | *PROGRAM* }
+|	*UPDATE_FLAGS* := { **any** | **exist** | **noexist** }
 
 DESCRIPTION
 ===========
diff --git a/tools/bpf/bpftool/Documentation/bpftool-prog.rst b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
index 6620a81d9dc9..685a19e71fec 100644
--- a/tools/bpf/bpftool/Documentation/bpftool-prog.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool-prog.rst
@@ -10,13 +10,13 @@ tool for inspection and simple manipulation of eBPF progs
 SYNOPSIS
 ========
 
-|	**bpftool** prog show [*PROG*]
-|	**bpftool** prog dump xlated *PROG* [{file *FILE* | opcodes }]
-|	**bpftool** prog dump jited  *PROG* [{file *FILE* | opcodes }]
-|	**bpftool** prog pin *PROG* *FILE*
-|	**bpftool** prog help
+|	**bpftool** **prog show** [*PROG*]
+|	**bpftool** **prog dump xlated** *PROG* [{**file** *FILE* | **opcodes**}]
+|	**bpftool** **prog dump jited**  *PROG* [{**file** *FILE* | **opcodes**}]
+|	**bpftool** **prog pin** *PROG* *FILE*
+|	**bpftool** **prog help**
 |
-|	*PROG* := { id *PROG_ID* | pinned *FILE* | tag *PROG_TAG* }
+|	*PROG* := { **id** *PROG_ID* | **pinned** *FILE* | **tag** *PROG_TAG* }
 
 DESCRIPTION
 ===========
diff --git a/tools/bpf/bpftool/Documentation/bpftool.rst b/tools/bpf/bpftool/Documentation/bpftool.rst
index 9c04cd6677bd..44e07799d54d 100644
--- a/tools/bpf/bpftool/Documentation/bpftool.rst
+++ b/tools/bpf/bpftool/Documentation/bpftool.rst
@@ -10,18 +10,20 @@ tool for inspection and simple manipulation of eBPF programs and maps
 SYNOPSIS
 ========
 
-	**bpftool** *OBJECT* { *COMMAND* | help }
+	**bpftool** *OBJECT* { *COMMAND* | **help** }
 
-	**bpftool** batch file *FILE*
+	**bpftool** **batch file** *FILE*
 
-	**bpftool** version
+	**bpftool** **version**
 
 	*OBJECT* := { **map** | **program** }
 
 	*MAP-COMMANDS* :=
-	{ show | dump | update | lookup | getnext | delete | pin | help }
+	{ **show** | **dump** | **update** | **lookup** | **getnext** | **delete**
+	| **pin** | **help** }
 
-	*PROG-COMMANDS* := { show | dump jited | dump xlated | pin | help }
+	*PROG-COMMANDS* := { **show** | **dump jited** | **dump xlated** | **pin**
+	| **help** }
 
 DESCRIPTION
 ===========
-- 
2.14.1
