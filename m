From: Eric Leblond <eric@regit.org>
Subject: [PATCH 0/8] tools lib bpf: fixes and functional upgrade
Date: Sun, 16 Oct 2016 23:18:26 +0200
Message-ID: <20161016211834.11732-1-eric@regit.org>
Cc: linux-kernel@vger.kernel.org, ast@fb.com
To: netdev@vger.kernel.org, wangnan0@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.regit.org ([37.187.126.138]:45246 "EHLO home.regit.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756957AbcJPVVM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 16 Oct 2016 17:21:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Here's a patchset on the libbpf library that can be found in
tools/lib/bpf.

Patch 0 to patch 4 add a new function to be able to set the BPF
program type. Till then program type such as network filter can't
be loaded by the library:

* tools lib bpf: add error functions
* uapi linux bpf: add max value to enum
* tools: Sync tools/include/uapi/linux/bpf.h with the
* tools lib bpf: export function to set type

Patch 5 is adding functions that were missing to handle maps in
userspace.

* tools lib bpf: add missing functions

Patch 7 fixes a bug in the parsing of BPF ELF file.

* tools lib bpf: fix maps resolution

Patch 8 update 'make install' to install the header on the system.

* tools lib bpf: install header file


Patchset statistics:
 include/uapi/linux/bpf.h       |  1 +
 tools/include/uapi/linux/bpf.h | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 tools/lib/bpf/Makefile         | 11 +++++++++--
 tools/lib/bpf/bpf.c            | 35 ++++++++++++++++++++++++++++++++++-
 tools/lib/bpf/bpf.h            |  2 --
 tools/lib/bpf/libbpf.c         | 83 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------------------
 tools/lib/bpf/libbpf.h         | 12 +++++++++++-
 7 files changed, 166 insertions(+), 34 deletions(-)

Best regards,
