From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 3/3] bpf: update perf event helper functions documentation
Date: Thu, 25 May 2017 22:55:49 -0700
Message-ID: <20170526055549.557818-4-ast@fb.com>
References: <20170526055549.557818-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526055549.557818-1-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teng Qin <qinteng@fb.com>

This commit updates documentation of the bpf_perf_event_output and
bpf_perf_event_read helpers to match their implementation.

Signed-off-by: Teng Qin <qinteng@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h       | 11 +++++++----
 tools/include/uapi/linux/bpf.h | 11 +++++++----
 2 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 94dfa9def355..e78aece03628 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -313,8 +313,11 @@ union bpf_attr {
  *     @flags: room for future extensions
  *     Return: 0 on success or negative error
  *
- * u64 bpf_perf_event_read(&map, index)
- *     Return: Number events read or error code
+ * u64 bpf_perf_event_read(map, flags)
+ *     read perf event counter value
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     Return: value of perf event counter read or error code
  *
  * int bpf_redirect(ifindex, flags)
  *     redirect to another netdev
@@ -328,11 +331,11 @@ union bpf_attr {
  *     @skb: pointer to skb
  *     Return: realm if != 0
  *
- * int bpf_perf_event_output(ctx, map, index, data, size)
+ * int bpf_perf_event_output(ctx, map, flags, data, size)
  *     output perf raw sample
  *     @ctx: struct pt_regs*
  *     @map: pointer to perf_event_array map
- *     @index: index of event in the map
+ *     @flags: index of event in the map or bitmask flags
  *     @data: data on stack to be output as raw data
  *     @size: size of data
  *     Return: 0 on success or negative error
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 94dfa9def355..e78aece03628 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -313,8 +313,11 @@ union bpf_attr {
  *     @flags: room for future extensions
  *     Return: 0 on success or negative error
  *
- * u64 bpf_perf_event_read(&map, index)
- *     Return: Number events read or error code
+ * u64 bpf_perf_event_read(map, flags)
+ *     read perf event counter value
+ *     @map: pointer to perf_event_array map
+ *     @flags: index of event in the map or bitmask flags
+ *     Return: value of perf event counter read or error code
  *
  * int bpf_redirect(ifindex, flags)
  *     redirect to another netdev
@@ -328,11 +331,11 @@ union bpf_attr {
  *     @skb: pointer to skb
  *     Return: realm if != 0
  *
- * int bpf_perf_event_output(ctx, map, index, data, size)
+ * int bpf_perf_event_output(ctx, map, flags, data, size)
  *     output perf raw sample
  *     @ctx: struct pt_regs*
  *     @map: pointer to perf_event_array map
- *     @index: index of event in the map
+ *     @flags: index of event in the map or bitmask flags
  *     @data: data on stack to be output as raw data
  *     @size: size of data
  *     Return: 0 on success or negative error
-- 
2.9.3
