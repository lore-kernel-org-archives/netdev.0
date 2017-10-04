From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v3 0/3] tools: add bpftool
Date: Wed,  4 Oct 2017 08:40:29 -0700
Message-ID: <20171004154032.11413-1-jakub.kicinski@netronome.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        dsahern@gmail.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:44564 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752409AbdJDPkv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:40:51 -0400
Received: by mail-pg0-f44.google.com with SMTP id b1so5187645pge.1
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2017 08:40:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set adds bpftool to the tools/ directory.  The first 
patch renames tools/net to tools/bpf, the second one adds 
the new code, while the third adds simple documentation.

I was holding off reposting in case the verifier instruction
printing/lock removal patches would turn out to be an easy
task.  They may need some more review, I will post them
separately.


v3:
 - address Alexei's comments about output and docs.
v2:
 - report names, map ids, load time, uid;
 - add docs/man pages;
 - general cleanups & fixes.

Jakub Kicinski (3):
  tools: rename tools/net directory to tools/bpf
  tools: bpf: add bpftool
  tools: bpftool: add documentation

 MAINTAINERS                                      |   3 +-
 tools/Makefile                                   |  14 +-
 tools/{net => bpf}/Makefile                      |  18 +-
 tools/{net => bpf}/bpf_asm.c                     |   0
 tools/{net => bpf}/bpf_dbg.c                     |   0
 tools/{net => bpf}/bpf_exp.l                     |   0
 tools/{net => bpf}/bpf_exp.y                     |   0
 tools/{net => bpf}/bpf_jit_disasm.c              |   0
 tools/bpf/bpftool/Documentation/Makefile         |  34 ++
 tools/bpf/bpftool/Documentation/bpftool-map.txt  | 110 ++++
 tools/bpf/bpftool/Documentation/bpftool-prog.txt |  79 +++
 tools/bpf/bpftool/Documentation/bpftool.txt      |  34 ++
 tools/bpf/bpftool/Makefile                       |  86 +++
 tools/bpf/bpftool/common.c                       | 216 +++++++
 tools/bpf/bpftool/jit_disasm.c                   |  87 +++
 tools/bpf/bpftool/main.c                         | 212 +++++++
 tools/bpf/bpftool/main.h                         |  99 +++
 tools/bpf/bpftool/map.c                          | 744 +++++++++++++++++++++++
 tools/bpf/bpftool/prog.c                         | 456 ++++++++++++++
 19 files changed, 2180 insertions(+), 12 deletions(-)
 rename tools/{net => bpf}/Makefile (74%)
 rename tools/{net => bpf}/bpf_asm.c (100%)
 rename tools/{net => bpf}/bpf_dbg.c (100%)
 rename tools/{net => bpf}/bpf_exp.l (100%)
 rename tools/{net => bpf}/bpf_exp.y (100%)
 rename tools/{net => bpf}/bpf_jit_disasm.c (100%)
 create mode 100644 tools/bpf/bpftool/Documentation/Makefile
 create mode 100644 tools/bpf/bpftool/Documentation/bpftool-map.txt
 create mode 100644 tools/bpf/bpftool/Documentation/bpftool-prog.txt
 create mode 100644 tools/bpf/bpftool/Documentation/bpftool.txt
 create mode 100644 tools/bpf/bpftool/Makefile
 create mode 100644 tools/bpf/bpftool/common.c
 create mode 100644 tools/bpf/bpftool/jit_disasm.c
 create mode 100644 tools/bpf/bpftool/main.c
 create mode 100644 tools/bpf/bpftool/main.h
 create mode 100644 tools/bpf/bpftool/map.c
 create mode 100644 tools/bpf/bpftool/prog.c

-- 
2.14.1
