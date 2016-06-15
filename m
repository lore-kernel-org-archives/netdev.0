From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/3] bpf: improve fd array release
Date: Wed, 15 Jun 2016 22:47:11 +0200
Message-ID: <cover.1466021686.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42930 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbcFOUr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:47:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set improves BPF perf fd array map release wrt to purging
entries, first two extend the API as needed. Please see individual
patches for more details.

Thanks!

Daniel Borkmann (3):
  bpf, maps: add release callback
  bpf, maps: extend map_fd_get_ptr arguments
  bpf, maps: flush own entries on perf map release

 include/linux/bpf.h      |  24 ++++++++--
 kernel/bpf/arraymap.c    | 116 +++++++++++++++++++++++++++++++++--------------
 kernel/bpf/syscall.c     |  13 +++++-
 kernel/trace/bpf_trace.c |  18 ++++----
 4 files changed, 122 insertions(+), 49 deletions(-)

-- 
1.9.3
