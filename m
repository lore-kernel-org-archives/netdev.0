From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] BPF direct packet access improvements
Date: Tue, 20 Sep 2016 00:26:11 +0200
Message-ID: <cover.1474323281.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49349 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbcISW01 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 18:26:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds write support to the currently available read support
for {cls,act}_bpf programs. First one is a fix for affected commit
sitting in net-next and prerequisite for the second one, last patch
adds a number of test cases against the verifier. For details, please
see individual patches.

Thanks!

Daniel Borkmann (3):
  bpf, verifier: enforce larger zero range for pkt on overloading stack buffs
  bpf: direct packet write and access for helpers for clsact progs
  bpf: add test cases for direct packet access

 include/linux/bpf.h         |   4 +-
 include/linux/skbuff.h      |  14 +-
 include/uapi/linux/bpf.h    |  21 +++
 kernel/bpf/helpers.c        |   3 +
 kernel/bpf/verifier.c       |  56 ++++--
 net/core/filter.c           | 134 ++++++++++++--
 samples/bpf/test_verifier.c | 433 +++++++++++++++++++++++++++++++++++++++++++-
 7 files changed, 627 insertions(+), 38 deletions(-)

-- 
1.9.3
