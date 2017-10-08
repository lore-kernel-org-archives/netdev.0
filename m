From: Petr Vorel <petr.vorel@gmail.com>
Subject: [PATCH] tests: Remove bashisms (s/source/.)
Date: Sun,  8 Oct 2017 16:39:16 +0200
Message-ID: <20171008143916.21813-1-petr.vorel@gmail.com>
Cc: Petr Vorel <petr.vorel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35314 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753681AbdJHOj0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 10:39:26 -0400
Received: by mail-wm0-f67.google.com with SMTP id b189so17419981wmd.2
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 07:39:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Petr Vorel <petr.vorel@gmail.com>
---
 testsuite/tests/ip/link/new_link.t            | 2 +-
 testsuite/tests/ip/link/show_dev_wo_vf_rate.t | 2 +-
 testsuite/tests/ip/netns/set_nsid.t           | 2 +-
 testsuite/tests/ip/netns/set_nsid_batch.t     | 2 +-
 testsuite/tests/ip/route/add_default_route.t  | 4 ++--
 testsuite/tests/ip/tunnel/add_tunnel.t        | 2 +-
 testsuite/tests/tc/cls-testbed.t              | 2 +-
 testsuite/tests/tc/dsmark.t                   | 2 +-
 testsuite/tests/tc/pedit.t                    | 2 +-
 9 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/testsuite/tests/ip/link/new_link.t b/testsuite/tests/ip/link/new_link.t
index 699adbcd..c17650a2 100755
--- a/testsuite/tests/ip/link/new_link.t
+++ b/testsuite/tests/ip/link/new_link.t
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 ts_log "[Testing add/del virtual links]"
 
diff --git a/testsuite/tests/ip/link/show_dev_wo_vf_rate.t b/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
index a600ba65..5b3c004e 100755
--- a/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
+++ b/testsuite/tests/ip/link/show_dev_wo_vf_rate.t
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 NL_FILE="tests/ip/link/dev_wo_vf_rate.nl"
 ts_ip "$0" "Show VF devices w/o VF rate info" -d monitor file $NL_FILE
diff --git a/testsuite/tests/ip/netns/set_nsid.t b/testsuite/tests/ip/netns/set_nsid.t
index 606d45ab..8f8c7792 100755
--- a/testsuite/tests/ip/netns/set_nsid.t
+++ b/testsuite/tests/ip/netns/set_nsid.t
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 ts_log "[Testing netns nsid]"
 
diff --git a/testsuite/tests/ip/netns/set_nsid_batch.t b/testsuite/tests/ip/netns/set_nsid_batch.t
index abb3f1bb..196fd4b3 100755
--- a/testsuite/tests/ip/netns/set_nsid_batch.t
+++ b/testsuite/tests/ip/netns/set_nsid_batch.t
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 ts_log "[Testing netns nsid in batch mode]"
 
diff --git a/testsuite/tests/ip/route/add_default_route.t b/testsuite/tests/ip/route/add_default_route.t
index e5ea6473..0b566f1f 100755
--- a/testsuite/tests/ip/route/add_default_route.t
+++ b/testsuite/tests/ip/route/add_default_route.t
@@ -1,6 +1,6 @@
-#!/bin/sh
+#!/bin/bash
 
-source lib/generic.sh
+. lib/generic.sh
 
 ts_log "[Testing add default route]"
 
diff --git a/testsuite/tests/ip/tunnel/add_tunnel.t b/testsuite/tests/ip/tunnel/add_tunnel.t
index 18f6e370..3f5a9d3c 100755
--- a/testsuite/tests/ip/tunnel/add_tunnel.t
+++ b/testsuite/tests/ip/tunnel/add_tunnel.t
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 TUNNEL_NAME="tunnel_test_ip"
 
diff --git a/testsuite/tests/tc/cls-testbed.t b/testsuite/tests/tc/cls-testbed.t
index 2afc26fc..d5c21e5c 100755
--- a/testsuite/tests/tc/cls-testbed.t
+++ b/testsuite/tests/tc/cls-testbed.t
@@ -1,7 +1,7 @@
 #!/bin/bash
 # vim: ft=sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 QDISCS="cbq htb dsmark"
 
diff --git a/testsuite/tests/tc/dsmark.t b/testsuite/tests/tc/dsmark.t
index 6934165e..177585e6 100755
--- a/testsuite/tests/tc/dsmark.t
+++ b/testsuite/tests/tc/dsmark.t
@@ -1,7 +1,7 @@
 #!/bin/bash
 # vim: ft=sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 ts_qdisc_available "dsmark"
 if [ $? -eq 0 ]; then
diff --git a/testsuite/tests/tc/pedit.t b/testsuite/tests/tc/pedit.t
index e9b6c333..8d531a05 100755
--- a/testsuite/tests/tc/pedit.t
+++ b/testsuite/tests/tc/pedit.t
@@ -1,6 +1,6 @@
 #!/bin/sh
 
-source lib/generic.sh
+. lib/generic.sh
 
 DEV="$(rand_dev)"
 ts_ip "$0" "Add $DEV dummy interface" link add dev $DEV type dummy
-- 
2.14.2
