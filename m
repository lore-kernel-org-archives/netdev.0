From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/14] netlink: add RX/TX-ring support to netlink diag
Date: Tue, 23 Apr 2013 15:23:39 -0400 (EDT)
Message-ID: <20130423.152339.1457379838723241885.davem@davemloft.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
	<1366217229-22705-12-git-send-email-kaber@trash.net>
	<3020335.4HTe7KSVvr@cpaasch-mac>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <3020335.4HTe7KSVvr@cpaasch-mac>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 23 Apr 2013 20:28:35 +0200

> Hello,
> 
> On Wednesday 17 April 2013 18:47:06 Patrick McHardy wrote:
>> +       mutex_lock(&nlk->pg_vec_lock);
>> +       ret = sk_diag_put_ring(&nlk->rx_ring, NETLINK_DIAG_RX_RING, nlskb);
>> +       if (!ret)
>> +               ret = sk_diag_put_ring(&nlk->tx_ring, NETLINK_DIAG_TX_RING,
>> +                                      nlskb);
>> +       mutex_unlock(&nlk->pg_vec_lock);
> 
> this produces a build-error, if CONFIG_NETLINK_MMAP=n:

See:

	http://marc.info/?l=linux-netdev&m=136674481328037&w=2
