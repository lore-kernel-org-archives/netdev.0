From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Tool: netperf-wrapper and qdisc bulking
Date: Fri, 12 Sep 2014 12:40:46 +0200
Message-ID: <20140912124046.68c6615b@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64541 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235AbaILKlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 06:41:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I going to use the tool called: "netperf-wrapper", for testing my qdisc
bulking patches.  It is very useful for network measurements, that
involves running multiple concurrent instances of testing tools
(primarily netperf and ping)

For others to get easily started using this tool, I've written a mini-tutorial:
 http://netoptimizer.blogspot.dk/2014/09/mini-tutorial-for-netperf-wrapper-setup.html

I'm currently using it for testing the Head-of-Line blocking issues
that bulking packets from the qdisc layer can possibly cause.

For that I've added an extra test called "tcp_upload_prio":
 https://github.com/tohojo/netperf-wrapper/commit/1e6b755e8051b6

More detail on these test results will follow (likely next week)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
