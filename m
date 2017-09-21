From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 master 0/2] BPF/XDP json follow-up
Date: Thu, 21 Sep 2017 10:42:27 +0200
Message-ID: <cover.1505956723.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40219 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751798AbdIUImj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 04:42:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After merging net-next branch into master, Stephen asked to
fix up json dump for XDP as there were some merge conflicts,
so here it is.

Thanks!

Daniel Borkmann (2):
  json: move json printer to common library
  bpf: properly output json for xdp

 include/json_print.h |  71 ++++++++++++++++
 ip/Makefile          |   2 +-
 ip/ip_common.h       |  65 ++------------
 ip/ip_print.c        | 233 ---------------------------------------------------
 ip/iplink_xdp.c      |  74 +++++++++-------
 lib/Makefile         |   2 +-
 lib/bpf.c            |  19 +++--
 lib/json_print.c     | 231 ++++++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 369 insertions(+), 328 deletions(-)
 create mode 100644 include/json_print.h
 delete mode 100644 ip/ip_print.c
 create mode 100644 lib/json_print.c

-- 
1.9.3
