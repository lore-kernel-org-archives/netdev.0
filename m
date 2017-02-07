From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v3 0/5] Miscellaneous fixes for BPF (perf tree)
Date: Tue,  7 Feb 2017 21:56:04 +0100
Message-ID: <20170207205609.8035-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series brings some fixes and small improvements to the BPF library and
samples.

This is intended for the perf tree and apply on e06094ab6755 ("Merge
remote-tracking branch 'tip/perf/urgent' into perf/core").

Changes since v2:
* add this cover letter

Changes since v1:
* exclude patches not intended for the perf tree

Regards,

Mickaël Salaün (5):
  bpf: Add missing header to the library
  bpf: Simplify bpf_load_program() error handling in the library
  samples/bpf: Ignore already processed ELF sections
  samples/bpf: Reset global variables
  samples/bpf: Add missing header

 samples/bpf/bpf_load.c     |  7 +++++++
 samples/bpf/tracex5_kern.c |  1 +
 tools/lib/bpf/bpf.c        | 18 ++++++------------
 tools/lib/bpf/bpf.h        |  1 +
 4 files changed, 15 insertions(+), 12 deletions(-)

-- 
2.11.0
