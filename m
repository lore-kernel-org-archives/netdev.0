From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 0/3] tools: add bpftool
Date: Mon,  2 Oct 2017 16:11:27 -0700
Message-ID: <20171002231130.12406-1-jakub.kicinski@netronome.com>
Cc: daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:49649 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751104AbdJBXLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 19:11:54 -0400
Received: by mail-pg0-f41.google.com with SMTP id v13so3750545pgq.6
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 16:11:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set adds bpftool to the tools/ directory.  The first 
patch renames tools/net to tools/bpf, the second one adds 
the new code, while the third adds simple documentation.

v2:
 - report names, map ids, load time, uid;
 - add docs/man pages;
 - general cleanups & fixes.

Thanks to David Beckett for help with docs and testing.

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
 tools/bpf/bpftool/Documentation/bpftool-prog.txt |  81 +++
 tools/bpf/bpftool/Documentation/bpftool.txt      |  34 ++
 tools/bpf/bpftool/Makefile                       |  86 +++
 tools/bpf/bpftool/common.c                       | 215 +++++++
 tools/bpf/bpftool/jit_disasm.c                   |  87 +++
 tools/bpf/bpftool/main.c                         | 212 +++++++
 tools/bpf/bpftool/main.h                         |  99 +++
 tools/bpf/bpftool/map.c                          | 744 +++++++++++++++++++++++
 tools/bpf/bpftool/prog.c                         | 427 +++++++++++++
 19 files changed, 2152 insertions(+), 12 deletions(-)
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
