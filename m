From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 0/4] net_sched: bulk dequeue and deferred drops
Date: Wed, 22 Jun 2016 16:47:36 +0200
Message-ID: <20160622164736.0ab98e6b@redhat.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751146AbcFVOsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 10:48:11 -0400
In-Reply-To: <1466576212-15012-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 23:16:48 -0700
Eric Dumazet <edumazet@google.com> wrote:

> First patch adds an additional parameter to ->enqueue() qdisc method
> so that drops can be done outside of critical section
> (after locks are released).
> 
> Then fq_codel can have a small optimization to reduce number of cache
> lines misses during a drop event
> (possibly accumulating hundreds of packets to be freed).
> 
> A small htb change exports the backlog in class dumps.
> 
> Final patch adds bulk dequeue to qdiscs that were lacking this feature.
> 
> This series brings a nice qdisc performance increase (more than 80 %
> in some cases).

Thanks for working on this Eric! this is great work! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
