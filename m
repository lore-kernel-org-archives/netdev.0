From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] BPF update
Date: Wed, 15 Jul 2015 14:21:40 +0200
Message-ID: <cover.1436961536.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37684 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753510AbbGOMVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 08:21:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small helper allows for accessing net_cls cgroups classid. Please
see individual patches for more details.

Thanks!

Daniel Borkmann (2):
  cls_cgroup: factor out classid retrieval
  ebpf: add helper to retrieve net_cls cgroup id

 include/net/cls_cgroup.h | 29 +++++++++++++++++++++++++++++
 include/uapi/linux/bpf.h |  7 +++++++
 net/core/filter.c        | 15 +++++++++++++++
 net/sched/cls_cgroup.c   | 23 ++---------------------
 4 files changed, 53 insertions(+), 21 deletions(-)

-- 
1.9.3
