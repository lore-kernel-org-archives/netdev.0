From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: pktgen: packet bursting via
 skb->xmit_more
Date: Wed, 01 Oct 2014 22:08:39 -0400 (EDT)
Message-ID: <20141001.220839.1118640596408366269.davem@davemloft.net>
References: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, brouer@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaJBCIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 22:08:41 -0400
In-Reply-To: <1412124801-32096-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Tue, 30 Sep 2014 17:53:21 -0700

> This patch demonstrates the effect of delaying update of HW tailptr.
> (based on earlier patch by Jesper)
> 
> burst=1 is the default. It sends one packet with xmit_more=false
> burst=2 sends one packet with xmit_more=true and
>         2nd copy of the same packet with xmit_more=false
> burst=3 sends two copies of the same packet with xmit_more=true and
>         3rd copy with xmit_more=false
> 
> Performance with ixgbe (usec 30):
> burst=1  tx:9.2 Mpps
> burst=2  tx:13.5 Mpps
> burst=3  tx:14.5 Mpps full 10G line rate
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, great work.
