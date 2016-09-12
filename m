From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] Misc cls_bpf/act_bpf improvements
Date: Mon, 12 Sep 2016 23:38:41 +0200
Message-ID: <cover.1473715365.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42371 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbcILVjA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 17:39:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two minor improvements to {cls,act}_bpf. For details please see
individual patches.

Thanks!

Daniel Borkmann (2):
  bpf: drop unnecessary test in cls_bpf_classify and tcf_bpf
  bpf: use skb_at_tc_ingress helper in tcf_bpf

 net/sched/act_bpf.c | 5 +----
 net/sched/cls_bpf.c | 3 ---
 2 files changed, 1 insertion(+), 7 deletions(-)

-- 
1.9.3
