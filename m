From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v10 net-next 0/2] load imm64 insn and uapi/linux/bpf.h
Date: Thu,  4 Sep 2014 22:17:16 -0700
Message-ID: <1409894238-9055-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:64525 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaIEFRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 01:17:31 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so21462862pab.17
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 22:17:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

V9->V10
- no changes, added Daniel's ack

Note they're on top of Hannes's patch in the same area [1]

V8 thread with 'why' reasoning and end goal [2]

Original set [3] of ~28 patches I'm planning to present in 4 stages:

  I. this 2 patches to fork off llvm upstreaming
 II. bpf syscall with manpage and map implementation
III. bpf program load/unload with verifier testsuite (1st user of
     instruction macros from bpf.h and 1st user of load imm64 insn)
 IV. tracing, etc

[1] http://patchwork.ozlabs.org/patch/385266/
[2] https://lkml.org/lkml/2014/8/27/628
[3] https://lkml.org/lkml/2014/8/26/859
