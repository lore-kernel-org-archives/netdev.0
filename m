From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] BPF helper improvements and cleanups
Date: Thu, 18 Aug 2016 01:00:37 +0200
Message-ID: <cover.1471473110.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34683 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752797AbcHQXCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:02:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds various improvements to BPF helpers, a cleanup to use
skb_pkt_type_ok() helper, addition of bpf_skb_change_tail(), a follow
up for event output helper and removing ifdefs around the cgroupv2
helper bits. For details please see individual patches.

The set is based against net-next tree, but requires a merge of net
into net-next first.

Thanks a lot!

Daniel Borkmann (4):
  bpf: use skb_pkt_type_ok helper in bpf_skb_change_type
  bpf: add bpf_skb_change_tail helper
  bpf: enable event output helper also for xdp types
  bpf: get rid of cgroup helper related ifdefs

 include/linux/skbuff.h   |  43 +++++++++++++-
 include/net/sock.h       |  10 ++++
 include/uapi/linux/bpf.h |  11 ++++
 net/core/filter.c        | 152 +++++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 204 insertions(+), 12 deletions(-)

-- 
1.9.3
