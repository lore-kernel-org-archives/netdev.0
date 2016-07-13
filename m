From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 0/3] pktgen samples: new scripts and removing older
 samples
Date: Wed, 13 Jul 2016 22:05:59 +0200
Message-ID: <20160713200525.21875.21960.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbcGMUGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 16:06:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is adding some pktgen sample scripts that I've been
using for a while[1], and they seams to relevant for more people.

Patchset also remove some of the older style pktgen samples.

[1] https://github.com/netoptimizer/network-testing/tree/master/pktgen

---

Jesper Dangaard Brouer (3):
      pktgen: add sample script pktgen_sample04_many_flows.sh
      pktgen: add sample script pktgen_sample05_flow_per_thread.sh
      pktgen: remove sample script pktgen.conf-1-1-rdos


 samples/pktgen/pktgen.conf-1-1-flows              |   67 ---------------
 samples/pktgen/pktgen.conf-1-1-rdos               |   64 --------------
 samples/pktgen/pktgen_sample04_many_flows.sh      |   93 +++++++++++++++++++++
 samples/pktgen/pktgen_sample05_flow_per_thread.sh |   81 ++++++++++++++++++
 4 files changed, 174 insertions(+), 131 deletions(-)
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-flows
 delete mode 100755 samples/pktgen/pktgen.conf-1-1-rdos
 create mode 100755 samples/pktgen/pktgen_sample04_many_flows.sh
 create mode 100755 samples/pktgen/pktgen_sample05_flow_per_thread.sh
