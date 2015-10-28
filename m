From: Wang Nan <wangnan0@huawei.com>
Subject: [RFC PATCH net-next 3/4] perf data: Add u32_hex data type
Date: Wed, 28 Oct 2015 10:55:04 +0000
Message-ID: <1446029705-199659-4-git-send-email-wangnan0@huawei.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lizefan@huawei.com>, <pi3orama@163.com>, <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Wang Nan <wangnan0@huawei.com>,
	Alexei Starovoitov <ast@plumgrid.com>
To: <acme@kernel.org>, <ast@kernel.org>, <brendan.d.gregg@gmail.com>,
	<jolsa@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add hexdamical u32 to base data type, which is useful for raw output
because raw data are u32 aligned.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Brendan Gregg <brendan.d.gregg@gmail.com>
Cc: Jiri Olsa <jolsa@kernel.org>
---
 tools/perf/util/data-convert-bt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tools/perf/util/data-convert-bt.c b/tools/perf/util/data-convert-bt.c
index 5bfc119..34cd1e4 100644
--- a/tools/perf/util/data-convert-bt.c
+++ b/tools/perf/util/data-convert-bt.c
@@ -63,6 +63,7 @@ struct ctf_writer {
 			struct bt_ctf_field_type	*s32;
 			struct bt_ctf_field_type	*u32;
 			struct bt_ctf_field_type	*string;
+			struct bt_ctf_field_type	*u32_hex;
 			struct bt_ctf_field_type	*u64_hex;
 		};
 		struct bt_ctf_field_type *array[6];
@@ -982,6 +983,7 @@ do {							\
 	CREATE_INT_TYPE(cw->data.u64, 64, false, false);
 	CREATE_INT_TYPE(cw->data.s32, 32, true,  false);
 	CREATE_INT_TYPE(cw->data.u32, 32, false, false);
+	CREATE_INT_TYPE(cw->data.u32_hex, 32, false, true);
 	CREATE_INT_TYPE(cw->data.u64_hex, 64, false, true);
 
 	cw->data.string  = bt_ctf_field_type_string_create();
-- 
1.8.3.4
