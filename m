From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] Improve xdp_monitor samples/bpf
Date: Fri, 06 Oct 2017 10:41:36 +0200
Message-ID: <150727927390.4460.3200093291677318710.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751486AbdJFIlk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 04:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are some improvements to the xdp_monitor tool currently located
under samples/bpf/.  Once the tools library libbpf become more feature
complete, xdp_monitor should be converted to use it, and be moved into
tools/bpf/xdp/ or tools/xdp/.

---

Jesper Dangaard Brouer (3):
      samples/bpf: xdp_monitor first 8 bytes are not accessible by bpf
      samples/bpf: xdp_monitor also record xdp_exception tracepoint
      samples/bpf: xdp_monitor increase memory rlimit


 samples/bpf/xdp_monitor_kern.c |   60 +++++++++++++++-----
 samples/bpf/xdp_monitor_user.c |  119 +++++++++++++++++++++++++++++++---------
 2 files changed, 139 insertions(+), 40 deletions(-)
