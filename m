From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: pktgen scripts
Date: Wed, 13 May 2015 15:02:37 +0200
Message-ID: <20150513150237.0abf3628@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Robert Olsson <robert@herjulf.net>,
	Ben Greear <greearb@candelatech.com>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <borkmann@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933410AbbEMNDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 09:03:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexei,

I've cleaned up my pktgen scripts[1].  Do you think we should add them
instead of the sample scripts in "samples/pktgen/pktgen.conf-*" ?

The main difference is I'm replacing the "pgset" with functions not
needing global variable $PGDEV.  Three new functions reflect pktgen's
different components:
 * pg_ctrl()   control "pgctrl" (/proc/net/pktgen/pgctrl)
 * pg_thread() control the kernel threads and binding to devices
 * pg_set()    control setup of individual devices

I've named the sample scripts: "pktgen_sample{01,02,03}_desc.sh" in-order
to suggest a reading order.
I've also added a script named: "pktgen_bench_xmit_mode_netif_receive.sh"
which is basically your ingress benchmarking script.

[1] https://github.com/netoptimizer/network-testing/tree/master/pktgen
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
