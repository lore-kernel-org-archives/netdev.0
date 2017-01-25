From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] BPF tracepoints
Date: Wed, 25 Jan 2017 02:28:15 +0100
Message-ID: <cover.1485306168.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set adds tracepoints to BPF for better introspection and
debugging. The first two patches are prerequisite for the actual
third patch that adds the tracepoints. I think the first two are
small and straight forward enough that they could ideally go via
net-next, but I'm also open to other suggestions on how to route
them in case that's not applicable (it would reduce potential
merge conflicts on BPF side, though). For details, please see
individual patches.

Thanks a lot!

Daniel Borkmann (3):
  trace: add variant without spacing in trace_print_hex_seq
  lib, traceevent: add PRINT_HEX_STR variant
  bpf: add initial bpf tracepoints

 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  12 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  15 +-
 drivers/net/ethernet/qlogic/qede/qede_fp.c         |   4 +
 drivers/net/virtio_net.c                           |  12 +-
 include/linux/bpf_trace.h                          |   7 +
 include/linux/trace_events.h                       |   3 +-
 include/trace/events/bpf.h                         | 347 +++++++++++++++++++++
 include/trace/events/xdp.h                         |  53 ++++
 include/trace/trace_events.h                       |   8 +-
 kernel/bpf/core.c                                  |   9 +
 kernel/bpf/inode.c                                 |  17 +-
 kernel/bpf/syscall.c                               |  19 +-
 kernel/trace/trace_output.c                        |   7 +-
 tools/lib/traceevent/event-parse.c                 |  34 +-
 tools/lib/traceevent/event-parse.h                 |   1 +
 .../perf/util/scripting-engines/trace-event-perl.c |   1 +
 .../util/scripting-engines/trace-event-python.c    |   1 +
 18 files changed, 530 insertions(+), 23 deletions(-)
 create mode 100644 include/linux/bpf_trace.h
 create mode 100644 include/trace/events/bpf.h
 create mode 100644 include/trace/events/xdp.h

-- 
1.9.3
