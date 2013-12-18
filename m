From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Tue, 17 Dec 2013 21:30:33 -0500 (EST)
Message-ID: <20131217.213033.1019416869378407851.davem@davemloft.net>
References: <20131218125643.8ff140371e1f8c306327d354@canb.auug.org.au>
	<20131217.212145.893665929052097867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ffusco@redhat.com,
	dborkman@redhat.com, tgraf@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131217.212145.893665929052097867.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 17 Dec 2013 21:21:45 -0500 (EST)

> I'll try to fix this up, thanks for the report.

Here's what I committed, thanks again Stephen:

====================
[PATCH] lib: Add missing arch generic-y entries for asm-generic/hash.h

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/alpha/include/asm/Kbuild      | 1 +
 arch/arc/include/asm/Kbuild        | 1 +
 arch/arm/include/asm/Kbuild        | 1 +
 arch/arm64/include/asm/Kbuild      | 1 +
 arch/avr32/include/asm/Kbuild      | 1 +
 arch/blackfin/include/asm/Kbuild   | 1 +
 arch/c6x/include/asm/Kbuild        | 1 +
 arch/cris/include/asm/Kbuild       | 1 +
 arch/frv/include/asm/Kbuild        | 1 +
 arch/hexagon/include/asm/Kbuild    | 1 +
 arch/ia64/include/asm/Kbuild       | 3 ++-
 arch/m32r/include/asm/Kbuild       | 1 +
 arch/m68k/include/asm/Kbuild       | 1 +
 arch/metag/include/asm/Kbuild      | 1 +
 arch/microblaze/include/asm/Kbuild | 1 +
 arch/mips/include/asm/Kbuild       | 1 +
 arch/mn10300/include/asm/Kbuild    | 1 +
 arch/openrisc/include/asm/Kbuild   | 1 +
 arch/parisc/include/asm/Kbuild     | 1 +
 arch/powerpc/include/asm/Kbuild    | 3 ++-
 arch/s390/include/asm/Kbuild       | 1 +
 arch/score/include/asm/Kbuild      | 2 ++
 arch/sh/include/asm/Kbuild         | 1 +
 arch/sparc/include/asm/Kbuild      | 1 +
 arch/tile/include/asm/Kbuild       | 1 +
 arch/um/include/asm/Kbuild         | 1 +
 arch/unicore32/include/asm/Kbuild  | 1 +
 arch/xtensa/include/asm/Kbuild     | 1 +
 28 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index f01fb50..a73a8e2 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index 5943f7f..93e6ca9 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -47,3 +47,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index c38b58c..3278afe 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -34,3 +34,4 @@ generic-y += timex.h
 generic-y += trace_clock.h
 generic-y += unaligned.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 519f89f..626d4a9 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -51,3 +51,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 658001b..cfb9fe1 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -18,3 +18,4 @@ generic-y       += sections.h
 generic-y       += topology.h
 generic-y	+= trace_clock.h
 generic-y       += xor.h
+generic-y	+= hash.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index f2b4347..359d36f 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -45,3 +45,4 @@ generic-y += unaligned.h
 generic-y += user.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index fc0b3c3..d73bb85 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -57,3 +57,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index b06caf6..c5963b3 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -12,3 +12,4 @@ generic-y += trace_clock.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 74742dc..bc42f14 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -3,3 +3,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 67c3450..469d223 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -54,3 +54,4 @@ generic-y += ucontext.h
 generic-y += unaligned.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index f93ee08..283a831 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -4,4 +4,5 @@ generic-y += exec.h
 generic-y += kvm_para.h
 generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.h
+generic-y += hash.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 2b58c5f..932435a 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += exec.h
 generic-y += module.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index a5d27f2..7cc8c36 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -32,3 +32,4 @@ generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 84d0c1d..b716d80 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -53,3 +53,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index ce0bbf8..43eec33 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += syscalls.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 1acbb8b..2d7f650 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -14,3 +14,4 @@ generic-y += trace_clock.h
 generic-y += preempt.h
 generic-y += ucontext.h
 generic-y += xor.h
+generic-y += hash.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 74742dc..bc42f14 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -3,3 +3,4 @@ generic-y += clkdev.h
 generic-y += exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index da1951a..2e40f1c 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -69,3 +69,4 @@ generic-y += vga.h
 generic-y += word-at-a-time.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index a603b9e..75edd5f 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -5,3 +5,4 @@ generic-y += word-at-a-time.h auxvec.h user.h cputime.h emergency-restart.h \
 	  poll.h xor.h clkdev.h exec.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index d8f9d2f..6c0a955 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -3,4 +3,5 @@ generic-y += clkdev.h
 generic-y += rwsem.h
 generic-y += trace_clock.h
 generic-y += preempt.h
-generic-y += vtime.h
\ No newline at end of file
+generic-y += vtime.h
+generic-y += hash.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 7a5288f..8386a4a 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -3,3 +3,4 @@
 generic-y += clkdev.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index f3414ad..099e7ba 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -5,3 +5,5 @@ generic-y += clkdev.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
+
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 231efbb..0cd7198 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -35,3 +35,4 @@ generic-y += trace_clock.h
 generic-y += ucontext.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index bf39066..4b60a0c 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -17,3 +17,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += word-at-a-time.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index 22f3bd1..3793c75 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -39,3 +39,4 @@ generic-y += trace_clock.h
 generic-y += types.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index fdde187..75de4ab 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -4,3 +4,4 @@ generic-y += ftrace.h pci.h io.h param.h delay.h mutex.h current.h exec.h
 generic-y += switch_to.h clkdev.h
 generic-y += trace_clock.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 00045cb..3ef4f9d 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -61,3 +61,4 @@ generic-y += user.h
 generic-y += vga.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 228d6ae..d7efa15 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -29,3 +29,4 @@ generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += xor.h
 generic-y += preempt.h
+generic-y += hash.h
-- 
1.7.11.7
