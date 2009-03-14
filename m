From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: 3c59x: shared interrupt problem
Date: Sat, 14 Mar 2009 15:08:41 +0100
Message-ID: <20090314140841.GA17629@bayes.mathematik.tu-chemnitz.de>
References: <20090310081628.GA3217@newton.mathematik.tu-chemnitz.de> <20090310145542.499128ef.akpm@linux-foundation.org> <20090311113815.GB26526@newton.mathematik.tu-chemnitz.de> <20090313.155116.183062617.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, shemminger@vyatta.com,
	gerhard_pircher@gmx.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lana.hrz.tu-chemnitz.de ([134.109.132.3]:53273 "EHLO
	lana.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbZCNOIo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 10:08:44 -0400
Content-Disposition: inline
In-Reply-To: <20090313.155116.183062617.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 13, 2009 at 03:51:16PM -0700, David Miller wrote:
> > #### ChangeSet ####
> > 2003-05-19 10:27:49-07:00, akpm@digeo.com 
> >   [PATCH] 3c59x irqreturn fix
> >   
> >   Apparently boomerang_interrupt() is generating lots of "nobody cared"
> >   warnings - one per packet it seems.  Frankly, I don't have a clue why.
> >   
> >   These are ancient cards and the driver is otherwise stable, so just
> >   change it to return IRQ_HANDLED and move on...
> 
> So basically it's a band-aid because we didn't investigate why
> this happens.
> 
> I think we should put the change in, and then look into things
> properly if users report this issue again.
> 

Gerhard reported at least one of these "nobody cared" messages at shutdown
after applying this change. He wanted to provide us with further informations
about this issue next week. Best would be to put it in together with a fix.
So I would suggest to wait, perhaps we can fix it with his informations. 


> The code there right now is just completely wrong when the
> 3c59x interrupt is shared with another device.

Indeed.
