From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] BPF support for flow labels
Date: Wed,  9 Mar 2016 03:00:01 +0100
Message-ID: <cover.1457488298.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45212 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbcCICAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 21:00:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds support for tunnel key flow labels for vxlan
and geneve devices in collect meta data mode and eBPF support
for managing these. For details please see individual patches.

Thanks!

Daniel Borkmann (4):
  ip_tunnel: add support for setting flow label via collect metadata
  vxlan: support setting IPv6 flow label
  geneve: support setting IPv6 flow label
  bpf: support flow label for bpf_skb_{set,get}_tunnel_key

 drivers/net/geneve.c         | 35 +++++++++++++++++++++++++++--------
 drivers/net/vxlan.c          | 24 ++++++++++++++++++++----
 include/net/dst_metadata.h   |  5 ++++-
 include/net/ip_tunnels.h     |  4 +++-
 include/net/udp_tunnel.h     |  4 ++--
 include/net/vxlan.h          |  1 +
 include/uapi/linux/bpf.h     |  1 +
 include/uapi/linux/if_link.h |  2 ++
 net/core/filter.c            | 14 ++++++++++++--
 net/ipv6/ip6_udp_tunnel.c    |  6 +++---
 net/tipc/udp_media.c         |  2 +-
 11 files changed, 76 insertions(+), 22 deletions(-)

-- 
1.9.3
