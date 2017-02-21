From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] BPF fix with regards to unlocking
Date: Tue, 21 Feb 2017 16:09:32 +0100
Message-ID: <cover.1487688093.git.daniel@iogearbox.net>
Cc: ast@kernel.org, labbott@redhat.com, eric.dumazet@gmail.com,
        willemb@google.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56258 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdBUPJv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 10:09:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set fixes the issue Eric was reporting recently [1].
First patch is a prerequisite discussed with Laura that is
needed for the later fix in the second one. I've tested this
extensively and it does not reproduce anymore on my side
after the fix. Thanks & sorry about that!

  [1] https://www.spinics.net/lists/netdev/msg421877.html

Daniel Borkmann (2):
  arch: add ARCH_HAS_SET_MEMORY config
  bpf: fix unlocking of jited image when module ronx not set

 arch/Kconfig                  |  4 ++++
 arch/arm/Kconfig              |  1 +
 arch/arm64/Kconfig            |  1 +
 arch/arm64/net/bpf_jit_comp.c |  2 +-
 arch/s390/Kconfig             |  1 +
 arch/s390/net/bpf_jit_comp.c  |  2 +-
 arch/x86/Kconfig              |  1 +
 arch/x86/net/bpf_jit_comp.c   |  2 +-
 include/linux/filter.h        | 13 +++++++++++--
 9 files changed, 22 insertions(+), 5 deletions(-)

-- 
1.9.3
