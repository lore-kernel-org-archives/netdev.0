From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] bpf misc update
Date: Fri, 29 May 2015 23:23:05 +0200
Message-ID: <cover.1432912637.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:39917 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030227AbbE2VXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 17:23:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (2):
  ebpf: allow bpf_ktime_get_ns_proto also for networking
  ebpf: misc core cleanup

 include/linux/bpf.h      |  1 +
 kernel/bpf/core.c        | 73 ++++++++++++++++++++++++++++--------------------
 kernel/bpf/helpers.c     | 47 ++++++++++++++++++++-----------
 kernel/trace/bpf_trace.c | 12 --------
 net/core/filter.c        |  2 ++
 5 files changed, 75 insertions(+), 60 deletions(-)

-- 
1.9.3
