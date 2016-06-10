From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/2] bpf: couple of fixes
Date: Fri, 10 Jun 2016 21:19:05 +0200
Message-ID: <cover.1465578089.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52769 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752068AbcFJTTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 15:19:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are two fixes for BPF, one to introduce xmit recursion limiter for
tc bpf programs and the other one to reject filters a bit earlier. For
more details please see individual patches. I have no strong opinion
to which tree they should go, they apply to both, but I think net-next
seems okay to me.

Thanks!

Daniel Borkmann (2):
  bpf: enforce recursion limit on redirects
  bpf: reject wrong sized filters earlier

 include/linux/netdevice.h |  2 ++
 net/core/dev.c            |  6 ++--
 net/core/filter.c         | 78 +++++++++++++++++++++++++++++------------------
 3 files changed, 53 insertions(+), 33 deletions(-)

-- 
1.9.3
