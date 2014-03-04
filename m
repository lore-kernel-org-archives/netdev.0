From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 net-next 0/3] Extended BPF, converter, seccomp, doc
Date: Mon,  3 Mar 2014 21:18:21 -0800
Message-ID: <1393910304-4004-1-git-send-email-ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

V1 patches:
http://thread.gmane.org/gmane.linux.kernel/1605783
V2 patches:
http://thread.gmane.org/gmane.linux.kernel/1642325
V3 patches:
http://thread.gmane.org/gmane.linux.kernel/1656538

V4 summary:
- addressed Daniel comments
- RFC for seccomp with extended BPF
- added extended BPF design doc

Please review.
Thanks!

Alexei Starovoitov (3):
  Extended BPF interpreter and converter
  RFC: convert seccomp to use extended BPF
  Extended BPF documentation

 Documentation/networking/filter.txt |  181 ++++++++
 include/linux/filter.h              |    8 +-
 include/linux/netdevice.h           |    1 +
 include/linux/seccomp.h             |    1 -
 include/uapi/linux/filter.h         |   34 +-
 kernel/seccomp.c                    |  112 +++--
 net/core/filter.c                   |  807 ++++++++++++++++++++++++++++++++++-
 net/core/sysctl_net_core.c          |    7 +
 8 files changed, 1062 insertions(+), 89 deletions(-)

-- 
1.7.9.5
