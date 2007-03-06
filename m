From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: netlink recvmsg() and MSG_TRUNC
Date: Tue, 6 Mar 2007 15:57:50 -0800
Message-ID: <20070306155750.7827ab1d@freekitty>
References: <20070306.151953.112290310.davem@davemloft.net>
	<E1HOjP1-0003NM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net (David Miller), netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37724 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030736AbXCFX57 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 18:57:59 -0500
In-Reply-To: <E1HOjP1-0003NM-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Mar 2007 10:49:07 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David Miller <davem@davemloft.net> wrote:
> > 
> > I guess one thing the user could do when it sees MSG_TRUNC
> > is keep calling recvmsg() until the receive queue is emptied
> > of packets, in order to get that pesky nlk->cb cleared to
> > NULL, then resubmit.
> > 
> > But that's rediculous and complicated.
> > 
> > Any ideas?
> 
> Which netlink family generates (or needs to generate) unbounded
> messages to user-space? Or indeed which ones generate messages
> greater than 64K (or 4K for that matter)?
> 
> Cheers,

I know some commands send big blocks down of configuration information.
One example is netem statistical data, but there are others.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
