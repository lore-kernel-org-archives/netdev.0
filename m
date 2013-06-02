From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] icmp: avoid allocating large struct on stack
Date: Sun, 02 Jun 2013 09:14:42 +0800
Message-ID: <1370135682.2637.1.camel@cr0>
References: <1370057053-20519-1-git-send-email-amwang@redhat.com>
	 <1370064152.24311.19.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab3FBBOx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jun 2013 21:14:53 -0400
In-Reply-To: <1370064152.24311.19.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-31 at 22:22 -0700, Eric Dumazet wrote:
> On Sat, 2013-06-01 at 11:24 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > struct icmp_bxm is a large struct, reduce stack usage
> > by allocating it on heap.
> > 
> 
> Strange, I posted a patch like that some days ago.

Strange, why it isn't merged. :)

> 
> Please.
> 
> Read carefully this code and tell me if you do not leak memory.

Right, I missed some kfree.

> 
> For the record my patch was saving more stack space :

Please submit it as a normal patch?
