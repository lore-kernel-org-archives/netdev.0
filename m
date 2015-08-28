From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 net-next 0/2] support for '%s' in bpf_trace_printk
Date: Fri, 28 Aug 2015 15:56:21 -0700
Message-ID: <1440802583-5020-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2->v3:
fix the comment to mention that strncpy_from_unsafe() returns
the length of the string including the trailing NUL.

v1->v2:
patch 1: generalize FETCH_FUNC_NAME(memory, string) into
strncpy_from_unsafe()
patch 2: use it in bpf_trace_printk

Alexei Starovoitov (2):
  lib: introduce strncpy_from_unsafe()
  bpf: add support for %s specifier to bpf_trace_printk()

 include/linux/uaccess.h     |    2 ++
 kernel/trace/bpf_trace.c    |   32 ++++++++++++++++++++++++++++++--
 kernel/trace/trace_kprobe.c |   20 ++++----------------
 lib/strncpy_from_user.c     |   41 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 77 insertions(+), 18 deletions(-)

-- 
1.7.9.5
