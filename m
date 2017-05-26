From: David Daney <david.daney@cavium.com>
Subject: [PATCH 0/5] MIPS: Implement eBPF JIT.
Date: Thu, 25 May 2017 17:38:21 -0700
Message-ID: <20170526003826.10834-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

The first four patches improve MIPS uasm in preparation for use by the
JIT.  The final patch is the eBPF JIT implementation.

I am CCing netdev@ and the BPF maintainers for their comments, but
would expect Ralf to merge via the MIPS tree if and when it all looks
good.

David Daney (5):
  MIPS: Optimize uasm insn lookup.
  MIPS: Correctly define DBSHFL type instruction opcodes.
  MIPS: Add some instructions to uasm.
  MIPS: Sort uasm enum opcode elements.
  MIPS: Add support for eBPF JIT.

 arch/mips/Kconfig                 |    1 +
 arch/mips/include/asm/uasm.h      |   28 +
 arch/mips/include/uapi/asm/inst.h |    9 +-
 arch/mips/mm/uasm-micromips.c     |  188 +++--
 arch/mips/mm/uasm-mips.c          |  236 +++---
 arch/mips/mm/uasm.c               |   59 +-
 arch/mips/net/bpf_jit.c           | 1627 ++++++++++++++++++++++++++++++++++++-
 arch/mips/net/bpf_jit.h           |    7 +
 8 files changed, 1930 insertions(+), 225 deletions(-)

-- 
2.9.4
