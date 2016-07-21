From: Brenden Blanco <bblanco@plumgrid.com>
Subject: [PATCH net-next 0/3] misc cleanups for xdp
Date: Wed, 20 Jul 2016 17:22:32 -0700
Message-ID: <1469060555-20250-1-git-send-email-bblanco@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35295 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637AbcGUAXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 20:23:07 -0400
Received: by mail-pa0-f53.google.com with SMTP id iw10so22909322pac.2
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 17:23:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This addresses several of the non-blocking comments left over from the
xdp patch set. See individual patches for details.

Brenden Blanco (3):
  net/mlx4_en: use READ_ONCE when freeing xdp_prog
  rtnl: protect do_setlink from IFLA_XDP_ATTACHED
  bpf: make xdp sample variable names more meaningful

 drivers/net/ethernet/mellanox/mlx4/en_rx.c |  6 ++++--
 net/core/rtnetlink.c                       |  4 ++++
 samples/bpf/xdp1_kern.c                    | 12 ++++++------
 samples/bpf/xdp2_kern.c                    | 14 +++++++-------
 4 files changed, 21 insertions(+), 15 deletions(-)

-- 
2.8.2
