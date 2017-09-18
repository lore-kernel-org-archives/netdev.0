From: josef@toxicpanda.com
Subject: [PATCH 2/3] selftests: actually run the various net selftests
Date: Mon, 18 Sep 2017 13:32:59 -0400
Message-ID: <1505755982-7855-2-git-send-email-jbacik@fb.com>
References: <1505755982-7855-1-git-send-email-jbacik@fb.com>
Cc: Josef Bacik <jbacik@fb.com>, Shuah Khan <shuah@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
        netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505755982-7855-1-git-send-email-jbacik@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josef Bacik <jbacik@fb.com>

These self tests are just self contained binaries, they are not run by
any of the scripts in the directory.  This means they need to be marked
with TEST_GEN_PROGS to actually be run, not TEST_GEN_FILES.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 tools/testing/selftests/net/Makefile | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 3df542c84610..45a4e77a47c4 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -6,8 +6,8 @@ CFLAGS += -I../../../../usr/include/
 TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh rtnetlink.sh
 TEST_GEN_FILES =  socket
 TEST_GEN_FILES += psock_fanout psock_tpacket
-TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
-TEST_GEN_FILES += reuseport_dualstack msg_zerocopy reuseaddr_conflict
+TEST_GEN_PROGS += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
+TEST_GEN_PROGS += reuseport_dualstack msg_zerocopy reuseaddr_conflict
 
 include ../lib.mk
 
-- 
2.7.4
