From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] bpf: test_maps: fix typo "conenct" -> "connext"
Date: Wed, 30 Aug 2017 12:47:07 +0100
Message-ID: <20170830114707.28493-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to typo in printf error message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 tools/testing/selftests/bpf/test_maps.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 7059bb315a10..8fdaf2e21c8a 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -525,7 +525,7 @@ static void test_sockmap(int tasks, void *data)
 		addr.sin_port = htons(ports[i - 2]);
 		err = connect(sfd[i], (struct sockaddr *)&addr, sizeof(addr));
 		if (err) {
-			printf("failed to conenct\n");
+			printf("failed to connect\n");
 			goto out;
 		}
 	}
-- 
2.14.1
