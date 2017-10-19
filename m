From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/8] tools: bpftool: add a "version" command, and fix several items
Date: Thu, 19 Oct 2017 15:46:18 -0700
Message-ID: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:53659 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752268AbdJSWrC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:02 -0400
Received: by mail-pf0-f196.google.com with SMTP id t188so8113100pfd.10
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quentin says:

The first seven patches of this series bring several minor fixes to
bpftool. Please see individual commit logs for details.

Last patch adds a "version" commands to bpftool, which is in fact the
version of the kernel from which it was compiled.


Quentin Monnet (8):
  tools: bpftool: add pointer to file argument to print_hex()
  tools: bpftool: fix return value when all eBPF programs have been
    shown
  tools: bpftool: use err() instead of info() if there are too many
    insns
  tools: bpftool: add `bpftool prog help` as real command i.r.t exit
    code
  tools: bpftool: print only one error message on byte parsing failure
  tools: bpftool: print all relevant byte opcodes for "load double word"
  tools: bpftool: show that `opcodes` or `file FILE` should be exclusive
  tools: bpftool: add a command to display bpftool version

 tools/bpf/bpftool/Documentation/bpftool-prog.rst |  8 +++----
 tools/bpf/bpftool/Documentation/bpftool.rst      |  2 ++
 tools/bpf/bpftool/main.c                         | 22 +++++++++++++----
 tools/bpf/bpftool/main.h                         |  2 +-
 tools/bpf/bpftool/map.c                          | 22 ++++++++---------
 tools/bpf/bpftool/prog.c                         | 30 +++++++++++++++++-------
 6 files changed, 56 insertions(+), 30 deletions(-)

-- 
2.14.1
