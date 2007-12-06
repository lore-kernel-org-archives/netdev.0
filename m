From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 10/11][INET] Eliminate difference in actions
 of sysctl and proc handler for conf.all.forwarding
Date: Thu, 06 Dec 2007 03:14:55 -0800 (PST)
Message-ID: <20071206.031455.86121437.davem@davemloft.net>
References: <E1J04N1-0006uU-00@gondolin.me.apana.org.au>
	<20071205.213933.40987728.davem@davemloft.net>
	<20071206110601.GA30402@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751739AbXLFLOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 06:14:55 -0500
In-Reply-To: <20071206110601.GA30402@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 6 Dec 2007 22:06:01 +1100

> On Wed, Dec 05, 2007 at 09:39:33PM -0800, David Miller wrote:
> >
> > But we go back again to the question of how to get this "current
> > behavior" setting instantiated early enough.  So much stuff happens
> > via initrd's etc. before the real userland has a change to run things,
> > read setting from the real filesystem config giles, in order to change
> > this.
> 
> Perhaps a boot time command line option?

It's not pleasant but it would indeed work.
