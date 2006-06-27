From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Export accept queue len of a TCP listening socket via
 rx_queue
Date: Tue, 27 Jun 2006 13:29:15 -0700 (PDT)
Message-ID: <20060627.132915.85418118.davem@davemloft.net>
References: <E1FtDPD-0005mc-00@gondolin.me.apana.org.au>
	<1150997897.8365.11.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4049
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161282AbWF0U3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:29:16 -0400
To: sri@us.ibm.com
In-Reply-To: <1150997897.8365.11.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 22 Jun 2006 10:38:17 -0700

> On Thu, 2006-06-22 at 10:50 +1000, Herbert Xu wrote:
> > Sridhar Samudrala <sri@us.ibm.com> wrote:
> > >> 
> > >> What about using the same fields (rqueue/wqueue) as you did for /proc?
> > > 
> > > I meant extending tcp_info structure to add new fields. I think the user
> > > space also uses this structure.
> > 
> > What about putting it into inet_idiag_msg.idiag_[rw]queue instead?
> 
> OK. I was under the mistaken assumption that [rw]queue fields are exported
> via tcp_info. This makes it pretty simple to support netlink users also. 
> Here is the updated patch.

This looks fine.  Applied, thanks a lot Sridhar.
