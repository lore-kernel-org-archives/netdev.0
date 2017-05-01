From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/2] samples/bpf: two bug fixes to
 XDP_FLAGS_SKB_MODE attaching
Date: Mon, 01 May 2017 11:26:10 +0200
Message-ID: <149363073213.17600.4480290736818479957.stgit@firesoul>
References: <5607e461-b74f-f8b7-8d47-a5341259ddff@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: dsa@cumulusnetworks.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59200 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S376520AbdEAJ0P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 05:26:15 -0400
In-Reply-To: <5607e461-b74f-f8b7-8d47-a5341259ddff@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two small bugfixes for:
 commit 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")

---

Jesper Dangaard Brouer (2):
      samples/bpf: fix SKB_MODE flag to be a 32-bit unsigned int
      samples/bpf: fix XDP_FLAGS_SKB_MODE detach for xdp_tx_iptunnel


 samples/bpf/bpf_load.c             |    3 ++-
 samples/bpf/bpf_load.h             |    2 +-
 samples/bpf/xdp1_user.c            |    8 ++++----
 samples/bpf/xdp_tx_iptunnel_user.c |   10 +++++-----
 4 files changed, 12 insertions(+), 11 deletions(-)
