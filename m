From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH v3 0/3] Interface for TCP Metrics
Date: Wed,  5 Sep 2012 00:03:14 +0300
Message-ID: <1346792597-2427-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34423 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757673Ab2IDVAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Sep 2012 17:00:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patchset contains 3 patches, one for kernel
and two for iproute2. We add DUMP/GET/DEL support for
genl "tcp_metrics" and minimal support for filtering
by address prefix and family in user space.

	I tested show/del/flush, filtering by family, IPv4 prefix,
output for metrics such as rtt, rttvar, cwnd, ssthresh (after
modifying route). I didn't tested output for fast open.

	May be some corrections in output can be desired.

v2:
- patch 1: remove rcu_assign_pointer, add tcp_metrics_flush_all
- patch 2: properly flush by specifying address, improve man page

v3:
- patch 1: remove synchronize_rcu
- patch 2: create libgenl.h and libgenl.c
- new patch 3: use libgenl.c also in ipl2tp.c
