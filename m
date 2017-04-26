From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 0/6] bpf: list all loaded ebpf programs in /proc/bpf/programs
Date: Wed, 26 Apr 2017 20:24:13 +0200
Message-ID: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:50973 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933328AbdDZSYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now it seems difficult to list all active ebpf programs in a
system. This new /proc/bpf/programs node should help and print
basically essential information about loaded ebpf programs.

This should help an admin to get a quick look of what is going on in
his system.

Feedback welcome!

Hannes Frederic Sowa (6):
  bpf: bpf_lock needs only block bottom half
  bpf: rename bpf_kallsyms to bpf_progs, ksym_lnode to bpf_progs_head
  bpf: bpf_progs stores all loaded programs
  bpf: track if the bpf program was loaded with SYS_ADMIN capabilities
  bpf: add skeleton for procfs printing of bpf_progs
  bpf: show bpf programs

 include/linux/bpf.h      |   2 +-
 include/linux/filter.h   |  10 ++-
 include/uapi/linux/bpf.h |  32 ++++----
 kernel/bpf/core.c        | 195 +++++++++++++++++++++++++++++++++++++----------
 kernel/bpf/syscall.c     |  11 +--
 kernel/bpf/verifier.c    |   4 +-
 net/core/filter.c        |   6 +-
 7 files changed, 190 insertions(+), 70 deletions(-)

-- 
2.9.3
