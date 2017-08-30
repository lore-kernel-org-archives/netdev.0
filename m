From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next][V3] bpf: test_maps: fix typos, "conenct" and "listeen"
Date: Wed, 30 Aug 2017 18:15:25 +0100
Message-ID: <20170830171525.5688-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to typos in printf error messages:
"conenct" -> "connect"
"listeen" -> "listen"

thanks to Daniel Borkmann for spotting one of these mistakes

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 tools/testing/selftests/bpf/test_maps.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 7059bb315a10..4acc772a28c0 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -504,7 +504,7 @@ static void test_sockmap(int tasks, void *data)
 		}
 		err = listen(sfd[i], 32);
 		if (err < 0) {
-			printf("failed to listeen\n");
+			printf("failed to listen\n");
 			goto out;
 		}
 	}
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
