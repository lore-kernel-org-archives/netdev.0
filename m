From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] bpf: bpf_perf_event_sample_control_proto can be static
Date: Wed, 14 Oct 2015 21:49:39 +0800
Message-ID: <20151014134939.GA4332@lkp-hsx03>
References: <201510142113.R6QU6uqp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, ast@plumgrid.com, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net, xiakaixu@huawei.com, wangnan0@huawei.com,
	linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: Kaixu Xia <xiakaixu@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444826277-94060-2-git-send-email-xiakaixu@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 bpf_trace.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index f261333..ade24a1 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -236,7 +236,7 @@ static u64 bpf_perf_event_sample_control(u64 r1, u64 index, u64 flag, u64 r4, u6
 	return 0;
 }
 
-const struct bpf_func_proto bpf_perf_event_sample_control_proto = {
+static const struct bpf_func_proto bpf_perf_event_sample_control_proto = {
 	.func		= bpf_perf_event_sample_control,
 	.gpl_only	= false,
 	.ret_type	= RET_INTEGER,
