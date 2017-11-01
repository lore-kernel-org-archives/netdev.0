From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/2] nfp: bpf: rename ALU_OP_NEG and support BPF_NEG
Date: Wed,  1 Nov 2017 10:38:23 -0700
Message-ID: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:51608 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKARia (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:38:30 -0400
Received: by mail-pg0-f67.google.com with SMTP id p9so2687133pgc.8
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:38:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiong says:

  Compilers are starting to use BPF_NEG, for example LLVM. However, NFP
does not support JITing it. This patch set adds this. Unit test is added
as well.

  Meanwhile, the current NFP_ALU_NEG is actually doing bitwise NOT (one's
complement) operation, so the name is misleading. This patch set corrects
this.


Jiong Wang (2):
  nfp: bpf: rename ALU_OP_NEG to ALU_OP_NOT
  nfp: bpf: support [BPF_ALU | BPF_ALU64] | BPF_NEG

 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 26 +++++++++++++++++++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h |  2 +-
 2 files changed, 26 insertions(+), 2 deletions(-)

-- 
2.14.1
