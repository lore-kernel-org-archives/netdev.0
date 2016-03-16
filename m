From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] Minor BPF follow-ups
Date: Wed, 16 Mar 2016 01:42:48 +0100
Message-ID: <cover.1458085814.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38423 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbcCPAnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 20:43:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some minor last follow-ups I still had in my queue. The first one adds
readability support for __sk_buff's tc_classid member, the remaining
two are some minor cleanups. For details please see individual patches.

Thanks!

Daniel Borkmann (3):
  bpf: make skb->tc_classid also readable
  bpf, dst: add and use dst_tclassid helper
  ip_tunnels, bpf: define IP_TUNNEL_OPTS_MAX and use it

 include/net/dst.h         | 12 ++++++++++++
 include/net/ip_tunnels.h  |  7 +++++++
 net/core/filter.c         | 30 +++++++++---------------------
 net/ipv4/ip_tunnel_core.c |  6 ++++++
 net/openvswitch/flow.h    |  2 +-
 5 files changed, 35 insertions(+), 22 deletions(-)

-- 
1.9.3
