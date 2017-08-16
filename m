From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 0/2] bpf: sockmap build fixes
Date: Wed, 16 Aug 2017 15:01:52 -0700
Message-ID: <20170816220049.25438.62373.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: daniel@iogearbox.net, davem@davemloft.net, eric.dumazet@gmail.com,
        dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35871 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752266AbdHPWCG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 18:02:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id y129so6572889pgy.3
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 15:02:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two build fixes for sockmap, this should resolve the build errors
and warnings that were reported. Thanks everyone.

---

John Fastabend (2):
      bpf: sockmap state change warning fix
      bpf: sock_map fixes for !CONFIG_BPF_SYSCALL and !STREAM_PARSER


 include/linux/bpf.h       |   10 +++++++++-
 include/linux/bpf_types.h |    2 ++
 kernel/bpf/Makefile       |    5 ++++-
 kernel/bpf/core.c         |    1 +
 kernel/bpf/sockmap.c      |    3 +++
 5 files changed, 19 insertions(+), 2 deletions(-)
