From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/3] internal BPF jit for x64 and JITed seccomp
Date: Tue, 13 May 2014 19:50:44 -0700
Message-ID: <1400035847-7730-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@kernel.org>,
	Chema Gonzalez <chema@google.com>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:39295 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbaENCu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 22:50:56 -0400
Received: by mail-pa0-f52.google.com with SMTP id fa1so1062327pad.11
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 19:50:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Internal BPF JIT compiler for x86_64 replaces classic BPF JIT.
Use it in seccomp and in tracing filters (sent as separate patch)

Alexei Starovoitov (3):
  net: filter: x86: split bpf_jit_compile()
  net: filter: x86: internal BPF JIT
  seccomp: JIT compile seccomp filter

 arch/x86/net/bpf_jit.S      |   77 +--
 arch/x86/net/bpf_jit_comp.c | 1399 ++++++++++++++++++++++++-------------------
 include/linux/filter.h      |    3 +
 kernel/seccomp.c            |   29 +-
 net/core/filter.c           |    9 +-
 5 files changed, 824 insertions(+), 693 deletions(-)

-- 
1.7.9.5
