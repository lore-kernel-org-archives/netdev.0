From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] act_bpf update
Date: Fri, 20 Mar 2015 15:11:10 +0100
Message-ID: <cover.1426859241.git.daniel@iogearbox.net>
Cc: jiri@resnulli.us, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55541 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbbCTOLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 10:11:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds native eBPF support also to act_bpf and thus covers tc
with eBPF in the classifier *and* action part.

A link to iproute2 preview has been provided in patch 2 and the code
will be pushed out after Stephen has processed the classifier part
and helper bits for tc.

This set depends on ced585c83b27 ("act_bpf: allow non-default TC_ACT
opcodes as BPF exec outcome"), so a net into net-next merge would be
required first. Hope that's fine by you, Dave. ;)

Thanks a lot!

Daniel Borkmann (2):
  ebpf: add sched_act_type and map it to sk_filter's verifier ops
  act_bpf: add initial eBPF support for actions

 include/net/tc_act/tc_bpf.h        |   6 +-
 include/uapi/linux/bpf.h           |   1 +
 include/uapi/linux/tc_act/tc_bpf.h |   2 +
 kernel/bpf/verifier.c              |   1 +
 net/core/filter.c                  |   6 +
 net/sched/act_bpf.c                | 295 ++++++++++++++++++++++++++-----------
 6 files changed, 228 insertions(+), 83 deletions(-)

-- 
1.9.3
