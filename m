From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] icmp: avoid allocating large struct on
 stack
Date: Mon, 03 Jun 2013 00:29:22 -0700 (PDT)
Message-ID: <20130603.002922.1166398410777355169.davem@davemloft.net>
References: <1370221252-5728-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, joe@perches.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3FCH3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:29:23 -0400
In-Reply-To: <1370221252-5728-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon,  3 Jun 2013 09:00:52 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> struct icmp_bxm is a large struct, reduce stack usage
> by allocating it on heap.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Joe Perches <joe@perches.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks a lot.
