From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Wed, 28 Jun 2006 10:01:43 -0500
Message-ID: <1151506903.14895.58.camel@stevo-desktop>
References: <20060628.000715.95062023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rolandd@cisco.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:21604 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1751205AbWF1PBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 11:01:44 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060628.000715.95062023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 00:07 -0700, David Miller wrote:
> Roland, there is no way in the world we would have let support for
> RDMA into the kernel tree had we seen and reviewed it on netdev.  I've
> discussed this with Andrew Morton, and we'd like you to please revert
> all of the RDMA code from Linus's tree immedialtely.
> 
> Folks are well aware how against RDMA and TOE type schemes the Linux
> networking developers are.  So the fact that none of these RDMA
> changes went up for review on netdev strikes me as just a little bit
> more than suspicious.
> 
> Please do not do this again, thank you.

Dave,

There is no support for RDMA/TCP in linux today, nor in Roland's git
tree for that matter.  I have posted a patch series for RDMA/TCP core
support to lklm and netdev over the last few weeks and gone through 3
review cycles. (see "iWARP Core Changes" threads).  In addition, I
posted the Ammasso RDMA driver for review as well.  It also went through
3 review cycles.  

Based on review feedback and lack of any serious issues, it was my
understanding that everyone was comfortable with RDMA/TCP.  Nothing
underhand was going on here.  


Steve.

