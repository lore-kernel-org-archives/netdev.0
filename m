From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] BPF update
Date: Mon, 11 Jan 2016 01:16:37 +0100
Message-ID: <cover.1452385316.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53592 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757891AbcAKAQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 19:16:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds IPv6 support for bpf_skb_{set,get}_tunnel_key() helper.
It also exports flags to user space that are being used in helpers and
weren't exported thus far. For more details, please see the individual
patches.

Thanks!

Daniel Borkmann (2):
  bpf: export helper function flags and reject invalid ones
  bpf: support ipv6 for bpf_skb_{set,get}_tunnel_key

 include/uapi/linux/bpf.h |  26 +++++++++++-
 net/core/filter.c        | 106 +++++++++++++++++++++++++++++++++++++----------
 2 files changed, 110 insertions(+), 22 deletions(-)

-- 
1.9.3
