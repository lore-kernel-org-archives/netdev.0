From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 0/4] packet: add BPF and eBPF fanout modes
Date: Fri, 14 Aug 2015 11:50:23 -0400
Message-ID: <1439567427-19504-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, dborkman@redhat.com,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35429 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755204AbbHNPue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 11:50:34 -0400
Received: by qkbm65 with SMTP id m65so26826401qkb.2
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 08:50:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Allow programmable fanout modes. Support both classical BPF programs
passed directly and eBPF programs passed by file descriptor.

One use case is packet steering by deep packet inspection, for
instance for packet steering by application layer header fields.

Separate the configuration of the fanout mode and the configuration
of the program, to allow dynamic updates to the latter at runtime.

Willem de Bruijn (4):
  packet: add BPF fanout mode
  packet: add eBPF fanout mode
  selftests/net: test bpf fanout mode
  selftests/net: test eBPF fanout mode

 include/uapi/linux/if_packet.h             |   3 +
 net/packet/af_packet.c                     | 122 ++++++++++++++++++++++++++++-
 net/packet/internal.h                      |   5 +-
 tools/testing/selftests/net/psock_fanout.c |  69 +++++++++++++++-
 tools/testing/selftests/net/psock_lib.h    |  29 +++++--
 5 files changed, 214 insertions(+), 14 deletions(-)

-- 
2.5.0.276.gf5e568e
