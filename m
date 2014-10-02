From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2 net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Thu, 2 Oct 2014 12:44:36 +0200
Message-ID: <20141002124436.0d335b97@redhat.com>
References: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
	<20141001.220839.1118640596408366269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, edumazet@google.com, netdev@vger.kernel.org,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbaJBKom (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:44:42 -0400
In-Reply-To: <20141001.220839.1118640596408366269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Oct 2014 22:08:39 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue, 30 Sep 2014 17:53:21 -0700
> 
> > This patch demonstrates the effect of delaying update of HW tailptr.
> > (based on earlier patch by Jesper)
> > 
> > burst=1 is the default. It sends one packet with xmit_more=false
> > burst=2 sends one packet with xmit_more=true and
> >         2nd copy of the same packet with xmit_more=false
> > burst=3 sends two copies of the same packet with xmit_more=true and
> >         3rd copy with xmit_more=false
> > 
> > Performance with ixgbe (usec 30):
> > burst=1  tx:9.2 Mpps
> > burst=2  tx:13.5 Mpps
> > burst=3  tx:14.5 Mpps full 10G line rate
> > 
> > Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> 
> Applied, great work.

Updated my pktgen script "pktgen02_burst.sh" for supporting this new
"burst" option:
 https://github.com/netoptimizer/network-testing/commit/cb625712f8efb
 https://github.com/netoptimizer/network-testing/blob/master/pktgen/pktgen02_burst.sh

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
