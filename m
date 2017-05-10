From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/2] Two generic xdp related follow-ups
Date: Wed, 10 May 2017 03:31:29 +0200
Message-ID: <cover.1494379046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54339 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdEJBbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 21:31:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two follow-ups for the generic XDP API, would be great if
both could still be considered, since the XDP API is not
frozen yet. For details please see individual patches.

Thanks!

Daniel Borkmann (2):
  xdp: add flag to enforce driver mode
  xdp: disallow use of native and generic hook at once

 include/linux/netdevice.h          | 15 ++++++++--
 include/uapi/linux/if_link.h       |  6 ++--
 net/core/dev.c                     | 57 +++++++++++++++++++++++++-------------
 net/core/rtnetlink.c               | 19 +++++++------
 samples/bpf/xdp1_user.c            |  8 ++++--
 samples/bpf/xdp_tx_iptunnel_user.c |  7 ++++-
 6 files changed, 77 insertions(+), 35 deletions(-)

-- 
1.9.3
