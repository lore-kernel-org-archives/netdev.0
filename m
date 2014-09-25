From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] mlx4: exploit skb->xmit_more to conditionally
 send doorbell
Date: Thu, 25 Sep 2014 16:43:33 +0200
Message-ID: <20140925164333.7cba128a@redhat.com>
References: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbaIYOnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 10:43:41 -0400
In-Reply-To: <1411654669.16953.17.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Sep 2014 07:17:49 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> Tested with a modified pktgen version, I got a 40% increase of
> throughput.

Pktgen is artificial benchmarking, you know ;-) :-P

If you really must use pktgen for this, you can use an unmodified
pktgen against the qdisc layer by adding a VLAN interface on-top of the
device you want to test.  I blame John, for telling me this ;-)

/me running away
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
