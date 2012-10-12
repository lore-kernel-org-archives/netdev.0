From: Cong Wang <amwang@redhat.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 qfq_dequeue()
Date: Fri, 12 Oct 2012 09:25:04 +0800
Message-ID: <1350005104.31369.0.camel@cr0>
References: <1349687756.2707.21.camel@cr0>  <1349944709.3412.2.camel@cr0>
	 <1349967908.21172.9459.camel@edumazet-glaptop>
	 <1349968843.21172.9508.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@redhat.com>, rizzo@iet.unipi.it
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400Ab2JLBZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 21:25:18 -0400
In-Reply-To: <1349968843.21172.9508.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 17:20 +0200, Eric Dumazet wrote:
> 
> I just realize its a 2.6.32 redhat kernel, while QFQ is a 3.0 addition.
> 
> Can you reproduce the bug on current kernel (3.6 or git tree)
> 

Sure, the gdb backtrace is from the latest -net kernel.
