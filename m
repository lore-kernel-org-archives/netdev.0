From: Chenbo Feng <chenbofeng.kernel@gmail.com>
Subject: [PATCH net-next 0/2] net: core: Two Helper function about socket information
Date: Thu,  2 Feb 2017 12:59:48 -0800
Message-ID: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <chenbofeng.kernel@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34031 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751638AbdBBVAE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 16:00:04 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so272443pgv.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 13:00:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce two eBpf helper function to get the socket cookie and
socket uid for each packet. The helper function is useful when
the *sk field inside sk_buff is not empty.

Chenbo Feng (2):
  Add a helper function to get socket cookie in eBPF
  Add a eBPF helper function to retrieve socket uid

 include/linux/bpf.h       |  2 ++
 include/linux/sock_diag.h |  1 +
 include/uapi/linux/bpf.h  | 16 +++++++++++++++-
 net/core/filter.c         | 34 ++++++++++++++++++++++++++++++++++
 net/core/sock_diag.c      |  3 ++-
 5 files changed, 54 insertions(+), 2 deletions(-)

-- 
2.11.0.483.g087da7b7c-goog
