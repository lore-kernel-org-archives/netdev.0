From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v2] net: fix for a race condition in the inet frag code
Date: Tue, 4 Mar 2014 08:28:59 +0100
Message-ID: <20140304082859.33488091@redhat.com>
References: <1393855520-18334-1-git-send-email-nikolay@redhat.com>
	<1393885158-4116-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>, brouer@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47465 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756362AbaCDH3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2014 02:29:08 -0500
In-Reply-To: <1393885158-4116-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  3 Mar 2014 23:19:18 +0100
Nikolay Aleksandrov <nikolay@redhat.com> wrote:

> Fixes: 3ef0eb0db4bf ("net: frag, move LRU list maintenance outside of
> rwlock")
> 
> CC: Florian Westphal <fw@strlen.de>
> CC: Jesper Dangaard Brouer <brouer@redhat.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> v2: Add more information on the flow leading to the race and an example.
> I hope this is better :-)

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Good work, thanks a lot for finding this race bug!
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
