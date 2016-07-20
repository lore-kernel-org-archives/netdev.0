From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, elf: add official ELF machine define for eBPF
Date: Wed, 20 Jul 2016 20:17:47 +0200
Message-ID: <d7fb256f1011ef948809f1447f745da42da970a3.1469038166.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33543 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbcGTSSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 14:18:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the official BPF ELF e_machine value that was assigned recently [1,2]
and will be propagated to glibc, et al. LLVM is switching to it in 3.9
release.

  [1] https://github.com/llvm-mirror/llvm/commit/36b9c09330bfb5e771914cfe307588f30d5510d2
  [2] http://lists.iovisor.org/pipermail/iovisor-dev/2016-June/000266.html

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/elf-em.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/elf-em.h b/include/uapi/linux/elf-em.h
index c3fdfe7..cb5d1a5 100644
--- a/include/uapi/linux/elf-em.h
+++ b/include/uapi/linux/elf-em.h
@@ -40,6 +40,7 @@
 #define EM_TILEPRO	188	/* Tilera TILEPro */
 #define EM_MICROBLAZE	189	/* Xilinx MicroBlaze */
 #define EM_TILEGX	191	/* Tilera TILE-Gx */
+#define EM_BPF		247	/* Linux BPF - in-kernel virtual machine */
 #define EM_FRV		0x5441	/* Fujitsu FR-V */
 #define EM_AVR32	0x18ad	/* Atmel AVR32 */
 
-- 
1.9.3
