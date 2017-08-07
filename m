From: James Hogan <james.hogan@imgtec.com>
Subject: [RFC PATCH 0/2] bpf_trace_printk() fixes
Date: Mon, 7 Aug 2017 23:25:12 +0100
Message-ID: <20170807222514.24292-1-james.hogan@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        James Hogan <james.hogan@imgtec.com>,
        Steven Rostedt <rostedt@goodmis.org>,
        Ingo Molnar <mingo@redhat.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A couple of RFC fixes for bpf_trace_printk(). The first affects 32-bit
architectures in particular, the second is a theoretical uninitialised
variable fix.

Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: netdev@vger.kernel.org

James Hogan (2):
  bpf: Fix bpf_trace_printk on 32-bit architectures
  bpf: Initialise mod[] in bpf_trace_printk

 kernel/trace/bpf_trace.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

-- 
2.13.2
