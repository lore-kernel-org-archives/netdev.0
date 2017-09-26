From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/2] tools: add bpftool
Date: Tue, 26 Sep 2017 08:35:20 -0700
Message-ID: <20170926153522.31500-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        davem@davemloft.net, hannes@stressinduktion.org, dsahern@gmail.com,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:43403 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031415AbdIZPfg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 11:35:36 -0400
Received: by mail-pf0-f181.google.com with SMTP id y29so5720780pff.0
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 08:35:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I'm looking for a home for bpftool, Daniel suggested that 
tools/net could be a good place, since there are only BPF
utilities there already.

The tool should be complete for simple use cases and we
will continue extending it as we go along.  E.g. providing
disassembly of loaded programs directly using LLVM library
and JSON output are high on the priority list.

The first patch renames tools/net to tools/bpf, while the
second one adds the new code.


Jakub Kicinski (2):
  tools: rename tools/net directory to tools/bpf
  tools: bpf: add bpftool

 MAINTAINERS                         |   3 +-
 tools/Makefile                      |  20 +-
 tools/{net => bpf}/Makefile         |  18 +-
 tools/{net => bpf}/bpf_asm.c        |   0
 tools/{net => bpf}/bpf_dbg.c        |   0
 tools/{net => bpf}/bpf_exp.l        |   0
 tools/{net => bpf}/bpf_exp.y        |   0
 tools/{net => bpf}/bpf_jit_disasm.c |   0
 tools/bpf/bpftool/Makefile          |  80 ++++
 tools/bpf/bpftool/common.c          | 214 +++++++++++
 tools/bpf/bpftool/jit_disasm.c      |  83 ++++
 tools/bpf/bpftool/main.c            | 212 +++++++++++
 tools/bpf/bpftool/main.h            |  99 +++++
 tools/bpf/bpftool/map.c             | 728 ++++++++++++++++++++++++++++++++++++
 tools/bpf/bpftool/prog.c            | 392 +++++++++++++++++++
 15 files changed, 1834 insertions(+), 15 deletions(-)
 rename tools/{net => bpf}/Makefile (73%)
 rename tools/{net => bpf}/bpf_asm.c (100%)
 rename tools/{net => bpf}/bpf_dbg.c (100%)
 rename tools/{net => bpf}/bpf_exp.l (100%)
 rename tools/{net => bpf}/bpf_exp.y (100%)
 rename tools/{net => bpf}/bpf_jit_disasm.c (100%)
 create mode 100644 tools/bpf/bpftool/Makefile
 create mode 100644 tools/bpf/bpftool/common.c
 create mode 100644 tools/bpf/bpftool/jit_disasm.c
 create mode 100644 tools/bpf/bpftool/main.c
 create mode 100644 tools/bpf/bpftool/main.h
 create mode 100644 tools/bpf/bpftool/map.c
 create mode 100644 tools/bpf/bpftool/prog.c

-- 
2.14.1
