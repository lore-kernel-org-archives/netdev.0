From: Joe Perches <joe@perches.com>
Subject: [PATCH -next 0/2] seq_file/netfilter: Start removing returns from seq_<foo>
Date: Wed, 11 Dec 2013 19:44:10 -0800
Message-ID: <cover.1386819513.git.joe@perches.com>
Cc: Kees Cook <keescook@chromium.org>, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org
To: Alexander Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value from seq_printf/puts/putc/etc are frequently misused.
Start removing the uses of the return values.

Joe Perches (2):
  seq_file: Rename static bool seq_overflow to public bool seq_is_buf_full
  netfilter: Convert print_tuple functions to return void

 Documentation/filesystems/seq_file.txt       | 28 ++++++++++++++++------------
 fs/seq_file.c                                | 28 ++++++++++++++--------------
 include/linux/seq_file.h                     |  8 ++++++++
 include/net/netfilter/nf_conntrack_core.h    |  2 +-
 include/net/netfilter/nf_conntrack_l3proto.h |  4 ++--
 include/net/netfilter/nf_conntrack_l4proto.h |  4 ++--
 net/netfilter/nf_conntrack_l3proto_generic.c |  5 ++---
 net/netfilter/nf_conntrack_proto_dccp.c      | 10 +++++-----
 net/netfilter/nf_conntrack_proto_generic.c   |  5 ++---
 net/netfilter/nf_conntrack_proto_gre.c       | 10 +++++-----
 net/netfilter/nf_conntrack_proto_sctp.c      | 10 +++++-----
 net/netfilter/nf_conntrack_proto_tcp.c       | 10 +++++-----
 net/netfilter/nf_conntrack_proto_udp.c       | 10 +++++-----
 net/netfilter/nf_conntrack_proto_udplite.c   | 10 +++++-----
 net/netfilter/nf_conntrack_standalone.c      | 15 +++++++--------
 15 files changed, 84 insertions(+), 75 deletions(-)

-- 
1.8.1.2.459.gbcd45b4.dirty

