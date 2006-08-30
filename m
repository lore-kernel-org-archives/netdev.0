From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix sk->sk_filter field access
Date: Wed, 30 Aug 2006 16:16:17 -0700 (PDT)
Message-ID: <20060830.161617.85689252.davem@davemloft.net>
References: <20060830222042.GA21714@ms2.inr.ac.ru>
	<20060830.153259.59653494.davem@davemloft.net>
	<20060830231406.GA25736@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dim@openvz.org, netdev@vger.kernel.org, dev@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36066
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751636AbWH3XQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Aug 2006 19:16:16 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060830231406.GA25736@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Thu, 31 Aug 2006 03:14:06 +0400

> > Let us to fix bugs first, and then consider rewriting the locking.
> 
> To be honest, I think switching to RCU is the simplest bug fix.
> At least, it does not require to search where bh_lock_sock() is taken
> dn_queue_skb(), if it is not forgotten at all. :-)

Ok :-)

It is just that, I will have a hard time convincing people that this
is legitimate for 2.6.18, and we would like the bug to be fixed there.
