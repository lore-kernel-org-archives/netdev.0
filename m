From: David Miller <davem@davemloft.net>
Subject: [PATCH net-next 0/2] sparc64 eBPF JIT
Date: Tue, 18 Apr 2017 14:57:55 -0400 (EDT)
Message-ID: <20170418.145755.2169599085585206751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: sparclinux@vger.kernel.org
Return-path: <sparclinux-owner@vger.kernel.org>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This series adds an eBPF JIT for sparc64.

Sparc32 keeps having it's cBPF JIT after these changes.

Thanks to Daniel and Alexei for their invaluable feedback and review.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

since RFC:
 -- rework register allocation so that we don't have to emit move
    instructions to get the arguments into place for calls
 -- allow FP as source for 64-bit ALU move operations
 -- don't emit NOP instructions in prologue, instead do multiple
    passes so that all the branch offsets settle down
 -- remove unnecessary checks on imm64 loads that verifier does
 -- consistently use bpf2sparc[] instead of direct register references
