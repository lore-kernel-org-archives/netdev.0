From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 02/53] perf tools: Fix phony build target for build-test
Date: Mon, 11 Jan 2016 13:47:53 +0000
Message-ID: <1452520124-2073-3-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Namhyung Kim" <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

make_kernelsrc and make_kernelsrc_tools are skiped if a previous
build-test is done, because 'make build-test' creates two files with
same names. To avoid this, they should be included in .PHONY list.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
---
 tools/perf/tests/make | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/perf/tests/make b/tools/perf/tests/make
index c1fbb8e..130be7c 100644
--- a/tools/perf/tests/make
+++ b/tools/perf/tests/make
@@ -280,5 +280,5 @@ all: $(run) $(run_O) tarpkg make_kernelsrc make_kernelsrc_tools
 out: $(run_O)
 	@echo OK
 
-.PHONY: all $(run) $(run_O) tarpkg clean
+.PHONY: all $(run) $(run_O) tarpkg clean make_kernelsrc make_kernelsrc_tools
 endif # ifndef MK
-- 
1.8.3.4
