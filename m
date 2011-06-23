From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-2.6 PATCH 2/3] qlge:Fix printk priority so chip fatal
	errors are always reported.
Date: Thu, 23 Jun 2011 11:43:26 -0700
Message-ID: <20110623184326.GA26015@linux-ox1b.qlogic.org>
References: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com> <1308851544-25719-2-git-send-email-ron.mercer@qlogic.com> <1308855049.6688.19.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:3208
	"EHLO DB3EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759779Ab1FWTAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 15:00:04 -0400
Content-Disposition: inline
In-Reply-To: <1308855049.6688.19.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2011 at 11:50:49AM -0700, Joe Perches wrote:
> On Thu, 2011-06-23 at 10:52 -0700, Ron Mercer wrote:
> > From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> > Precedence of the printk should be at higher level so chip
> > 	fatal errors are always reported.
> 
> You probably want to use netdev_err then, not a masked
> netif_err when it is optionally not reported.
>

Thanks.  We will respin these after waiting a bit for more comments.

