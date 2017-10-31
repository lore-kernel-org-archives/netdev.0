From: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>
Subject: [PATCH net-next 0/3] tools: bpftool: show filenames of pinned objects
Date: Tue, 31 Oct 2017 16:36:29 +0900
Message-ID: <20171031073632.8140-1-bhole_prashant_q7@lab.ntt.co.jp>
Cc: Prashant Bhole <bhole_prashant_q7@lab.ntt.co.jp>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:37571 "EHLO
        tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdJaHvM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 03:51:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support to show pinned objects in object details.

Patch1 adds a funtionality to open a path in bpf-fs regardless of its object
type.

Patch2 adds actual functionality by scanning the bpf-fs once and adding
object information in hash table, with object id as a key. One object may be
associated with multiple paths because an object can be pinned multiple times

Patch3 adds command line option to enable this functionality. Making it optional
because scanning bpf-fs can be costly.


Prashant Bhole (3):
  tools: bpftool: open pinned object without type check
  tools: bpftool: show filenames of pinned objects
  tools: bpftool: optionally show filenames of pinned objects

 tools/bpf/bpftool/common.c | 85 ++++++++++++++++++++++++++++++++++++++++++++--
 tools/bpf/bpftool/main.c   | 18 +++++++++-
 tools/bpf/bpftool/main.h   | 19 ++++++++++-
 tools/bpf/bpftool/map.c    | 23 ++++++++++++-
 tools/bpf/bpftool/prog.c   | 24 +++++++++++++
 5 files changed, 164 insertions(+), 5 deletions(-)

-- 
1.8.3.1
