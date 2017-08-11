From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] Minor fix in bpf_convert_ctx_access
Date: Fri, 11 Aug 2017 18:31:23 +0200
Message-ID: <cover.1502468639.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41696 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753663AbdHKQbb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 12:31:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First one was found while trying to compile the kernel
with !CONFIG_NET_RX_BUSY_POLL.

Thanks!

Daniel Borkmann (2):
  net: fix compilation when busy poll is not enabled
  bpf: fix two missing target_size settings in bpf_convert_ctx_access

 include/net/busy_poll.h | 12 ++++++------
 net/core/filter.c       |  2 ++
 2 files changed, 8 insertions(+), 6 deletions(-)

-- 
1.9.3
