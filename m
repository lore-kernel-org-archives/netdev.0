From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next v2 0/2] Two Helper function about socket information
Date: Sun,  5 Feb 2017 18:17:26 -0800
Message-ID: <1486347448-15393-1-git-send-email-chenbofeng.kernel@gmail.com>
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Chenbo Feng <fengc@google.com>
To: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36608 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752036AbdBFCSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 21:18:08 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so7670290pgf.3
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 18:18:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chenbo Feng <fengc@google.com>

Introduce two eBpf helper function to get the socket cookie and
socket uid for each packet. The helper function is useful when
the *sk field inside sk_buff is not empty.

Chenbo Feng (2):
  Add a helper function to get socket cookie in eBPF
  Add a eBPF helper function to retrieve socket uid

 include/linux/sock_diag.h |  1 +
 include/uapi/linux/bpf.h  | 16 +++++++++++++++-
 net/core/filter.c         | 32 ++++++++++++++++++++++++++++++++
 net/core/sock_diag.c      |  2 +-
 4 files changed, 49 insertions(+), 2 deletions(-)

-- 
2.7.4
