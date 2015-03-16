From: Mark Einon <mark.einon@gmail.com>
Subject: [PATCH iproute2 2/2] ip: Harmonise usage references to show / list option
Date: Mon, 16 Mar 2015 09:59:10 +0000
Message-ID: <1426499950-6641-2-git-send-email-mark.einon@gmail.com>
References: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
Cc: netdev@vger.kernel.org, Mark Einon <mark.einon@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:38255 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbbCPJ72 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 05:59:28 -0400
Received: by wifj2 with SMTP id j2so38390538wif.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 02:59:26 -0700 (PDT)
In-Reply-To: <1426499950-6641-1-git-send-email-mark.einon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The majority of ip commands that implement show / list options reference
only the 'show' option in usage notes. Some others reference only
'list', while ip-tuntap references both. Additionally, ip-addrlabel and
ip-rule reference 'list' in usage notes while having an error message
that references 'show', which is confusing.

Harmonise all these references to be the current majority choice of
'show'.

Prefer alphabetical listing of options where changes are made.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---
 ip/ipaddrlabel.c | 2 +-
 ip/ipnetns.c     | 2 +-
 ip/iproute.c     | 2 +-
 ip/iprule.c      | 2 +-
 ip/iptoken.c     | 2 +-
 ip/iptuntap.c    | 2 +-
 ip/xfrm_policy.c | 2 +-
 ip/xfrm_state.c  | 2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index f6a638b..ab4a1e4 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -49,7 +49,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip addrlabel [ list | add | del | flush ] prefix PREFIX [ dev DEV ] [ label LABEL ]\n");
+	fprintf(stderr, "Usage: ip addrlabel [ add | del | flush | show ] prefix PREFIX [ dev DEV ] [ label LABEL ]\n");
 	exit(-1);
 }
 
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 45e234a..4b47fb4 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -23,7 +23,7 @@
 
 static int usage(void)
 {
-	fprintf(stderr, "Usage: ip netns list\n");
+	fprintf(stderr, "Usage: ip netns show\n");
 	fprintf(stderr, "       ip netns add NAME\n");
 	fprintf(stderr, "       ip netns set NAME NETNSID\n");
 	fprintf(stderr, "       ip [-all] netns delete [NAME]\n");
diff --git a/ip/iproute.c b/ip/iproute.c
index c842e85..b863e7b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -59,7 +59,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip route { list | flush } SELECTOR\n");
+	fprintf(stderr, "Usage: ip route { flush | show } SELECTOR\n");
 	fprintf(stderr, "       ip route save SELECTOR\n");
 	fprintf(stderr, "       ip route restore\n");
 	fprintf(stderr, "       ip route showdump\n");
diff --git a/ip/iprule.c b/ip/iprule.c
index 54ed753..95a28e6 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -32,7 +32,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip rule [ list | add | del | flush ] SELECTOR ACTION\n");
+	fprintf(stderr, "Usage: ip rule [ add | del | flush | show ] SELECTOR ACTION\n");
 	fprintf(stderr, "SELECTOR := [ not ] [ from PREFIX ] [ to PREFIX ] [ tos TOS ] [ fwmark FWMARK[/MASK] ]\n");
 	fprintf(stderr, "            [ iif STRING ] [ oif STRING ] [ pref NUMBER ]\n");
 	fprintf(stderr, "ACTION := [ table TABLE_ID ]\n");
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 655f160..e53dbca 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -38,7 +38,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip token [ list | set | get ] [ TOKEN ] [ dev DEV ]\n");
+	fprintf(stderr, "Usage: ip token [ get | set | show ] [ TOKEN ] [ dev DEV ]\n");
 	exit(-1);
 }
 
diff --git a/ip/iptuntap.c b/ip/iptuntap.c
index b9b28a1..de54f52 100644
--- a/ip/iptuntap.c
+++ b/ip/iptuntap.c
@@ -36,7 +36,7 @@ static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip tuntap { add | del | show | list | lst | help } [ dev PHYS_DEV ] \n");
+	fprintf(stderr, "Usage: ip tuntap { add | del | show | help } [ dev PHYS_DEV ] \n");
 	fprintf(stderr, "          [ mode { tun | tap } ] [ user USER ] [ group GROUP ]\n");
 	fprintf(stderr, "          [ one_queue ] [ pi ] [ vnet_hdr ] [ multi_queue ]\n");
 	fprintf(stderr, "\n");
diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index 2337d35..da732b8 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -59,7 +59,7 @@ static void usage(void)
 	fprintf(stderr, "        [ LIMIT-LIST ] [ TMPL-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy { delete | get } { SELECTOR | index INDEX } dir DIR\n");
 	fprintf(stderr, "        [ ctx CTX ] [ mark MARK [ mask MASK ] ] [ ptype PTYPE ]\n");
-	fprintf(stderr, "Usage: ip xfrm policy { deleteall | list } [ SELECTOR ] [ dir DIR ]\n");
+	fprintf(stderr, "Usage: ip xfrm policy { deleteall | show } [ SELECTOR ] [ dir DIR ]\n");
 	fprintf(stderr, "        [ index INDEX ] [ ptype PTYPE ] [ action ACTION ] [ priority PRIORITY ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm policy flush [ ptype PTYPE ]\n");
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 2ad3d8d..e7463fb 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -64,7 +64,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip xfrm state allocspi ID [ mode MODE ] [ mark MARK [ mask MASK ] ]\n");
 	fprintf(stderr, "        [ reqid REQID ] [ seq SEQ ] [ min SPI max SPI ]\n");
 	fprintf(stderr, "Usage: ip xfrm state { delete | get } ID [ mark MARK [ mask MASK ] ]\n");
-	fprintf(stderr, "Usage: ip xfrm state { deleteall | list } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
+	fprintf(stderr, "Usage: ip xfrm state { deleteall | show } [ ID ] [ mode MODE ] [ reqid REQID ]\n");
 	fprintf(stderr, "        [ flag FLAG-LIST ]\n");
 	fprintf(stderr, "Usage: ip xfrm state flush [ proto XFRM-PROTO ]\n");
 	fprintf(stderr, "Usage: ip xfrm state count\n");
-- 
2.1.4
