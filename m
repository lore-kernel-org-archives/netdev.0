From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2 0/2] Two generic xdp related follow-ups
Date: Fri, 12 May 2017 01:04:44 +0200
Message-ID: <cover.1494542162.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, kubakici@wp.pl,
        john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59587 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756524AbdEKXE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 19:04:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two follow-ups for the generic XDP API, would be great if
both could still be considered, since the XDP API is not
frozen yet. For details please see individual patches.

v1 -> v2:
  - Implemented feedback from Jakub Kicinski (reusing
    attribute on dump), thanks!
  - Rest as is.

Thanks!

Daniel Borkmann (2):
  xdp: add flag to enforce driver mode
  xdp: refine xdp api with regards to generic xdp

 include/linux/netdevice.h          |  8 ++++--
 include/uapi/linux/if_link.h       | 13 +++++++--
 net/core/dev.c                     | 57 +++++++++++++++++++++++++-------------
 net/core/rtnetlink.c               | 45 +++++++++++++++---------------
 samples/bpf/xdp1_user.c            |  8 ++++--
 samples/bpf/xdp_tx_iptunnel_user.c |  7 ++++-
 6 files changed, 90 insertions(+), 48 deletions(-)

-- 
1.9.3
