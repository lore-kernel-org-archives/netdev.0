From: Rolf Eike Beer <eb@emlix.com>
Subject: [PATCH 2/3] selftests: do not require bash to run bpf tests
Date: Wed, 14 Dec 2016 11:58:20 +0100
Message-ID: <3057464.DrP1iNtcaF@devpool21>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        linux-kernel@vger.kernel.org, Shuah Khan <shuahkh@osg.samsung.com>,
        Shuah Khan <shuah@kernel.org>
To: linux-kselftest@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From b9d6c1b7427d708ef2d4d57aac17b700b3694d71 Mon Sep 17 00:00:00 2001
From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Date: Wed, 14 Dec 2016 09:58:12 +0100
Subject: [PATCH 2/3] selftests: do not require bash to run bpf tests

Nothing in this minimal script seems to require bash. We often run these tests
on embedded devices where the only shell available is the busybox ash.

Signed-off-by: Rolf Eike Beer <eb@emlix.com>
---
 tools/testing/selftests/bpf/test_kmod.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/bpf/test_kmod.sh b/tools/testing/selftests/bpf/test_kmod.sh
index 92e627a..6d58cca 100755
--- a/tools/testing/selftests/bpf/test_kmod.sh
+++ b/tools/testing/selftests/bpf/test_kmod.sh
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/bin/sh
 
 SRC_TREE=../../../../
 
-- 
2.8.3


-- 
Rolf Eike Beer, emlix GmbH, http://www.emlix.com
Fon +49 551 30664-0, Fax +49 551 30664-11
Bertha-von-Suttner-Str. 9, 37085 Göttingen, Germany
Sitz der Gesellschaft: Göttingen, Amtsgericht Göttingen HR B 3160
Geschäftsführung: Heike Jordan, Dr. Uwe Kracke – Ust-IdNr.: DE 205 198 055

emlix – smart embedded open source
