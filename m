From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG] net: cpu offline cause napi stall
Date: Wed, 1 Jun 2011 20:12:54 +0200
Message-ID: <20110601181253.GA2374@osiris.boeblingen.de.ibm.com>
References: <20110601103356.GA45482@tuxmaker.boeblingen.de.ibm.com>
 <1306930399.3476.1.camel@edumazet-laptop>
 <20110601163628.GA2418@osiris.boeblingen.de.ibm.com>
 <1306947321.2890.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:59445 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752464Ab1FASM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 14:12:56 -0400
Content-Disposition: inline
In-Reply-To: <1306947321.2890.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2011 at 06:55:21PM +0200, Eric Dumazet wrote:
> > +	/* Append NAPI poll list from offline CPU. */
> > +	list_splice_init(&oldsd->poll_list, &sd->poll_list);
> >  
> >  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
> >  	local_irq_enable();
> 
> Please make sure we raise NET_RX_SOFTIRQ on new cpu if necessary.

Well, see two lines below the list_splice_init() call ;)
