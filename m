From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/4] BPF updates
Date: Fri, 16 Oct 2015 03:09:21 +0200
Message-ID: <cover.1444956943.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	tgraf@suug.ch, hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set adds support for persistent maps/progs. Please see
individual patches for further details.

A man-page update to bpf(2) will be sent afterwards, also a
iproute2 patch for support in tc.

Thanks!

Daniel Borkmann (4):
  bpf: abstract anon_inode_getfd invocations
  bpf: align and clean bpf_{map,prog}_get helpers
  bpf: add support for persistent maps/progs
  bpf: add sample usages for persistent maps/progs

 include/linux/bpf.h        |  23 +-
 include/uapi/linux/bpf.h   |  45 +---
 include/uapi/linux/magic.h |   1 +
 include/uapi/linux/xattr.h |   3 +
 kernel/bpf/Makefile        |   4 +-
 kernel/bpf/inode.c         | 614 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c       | 164 ++++++++++--
 kernel/bpf/verifier.c      |   3 +-
 samples/bpf/Makefile       |   2 +
 samples/bpf/fds_example.c  | 224 +++++++++++++++++
 samples/bpf/libbpf.c       |  20 ++
 samples/bpf/libbpf.h       |   3 +
 12 files changed, 1045 insertions(+), 61 deletions(-)
 create mode 100644 kernel/bpf/inode.c
 create mode 100644 samples/bpf/fds_example.c

-- 
1.9.3
