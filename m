From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: remove duplicated declaration of
 ip6_fragment()
Date: Tue, 22 Jan 2013 23:22:54 -0500 (EST)
Message-ID: <20130122.232254.854177940537154867.davem@davemloft.net>
References: <1358911327-12122-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752926Ab3AWEWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 23:22:55 -0500
In-Reply-To: <1358911327-12122-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed, 23 Jan 2013 11:22:07 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> It is declared in:
> include/net/ip6_route.h:187:int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
> 
> and net/ip6_route.h is already included.
> 
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
