From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/8] netpoll: use GFP_ATOMIC in slave_enable_netpoll()
 and __netpoll_setup()
Date: Tue, 07 Aug 2012 10:28:51 +0800
Message-ID: <1344306531.6917.2.camel@cr0>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	 <1344263012-4031-2-git-send-email-amwang@redhat.com>
	 <1344266405.26674.30.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37167 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757154Ab2HGC25 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 22:28:57 -0400
In-Reply-To: <1344266405.26674.30.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 17:20 +0200, Eric Dumazet wrote:
> On Mon, 2012-08-06 at 22:23 +0800, Cong Wang wrote:
> > slave_enable_netpoll() and __netpoll_setup() may be called
> > with read_lock() held, so should use GFP_ATOMIC to allocate
> > memory. Eric suggested to pass gfp flags to __netpoll_setup().
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> 
> You based this on net-next, but didnt add the net-next suffix in your
> [PATCH ...] description.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> 

Oh, it is default, isn't it? :-D Anyway, I will add it the next time
when I send network patches.

Thanks!
