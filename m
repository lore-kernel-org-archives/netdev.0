From: =?iso-8859-1?Q?Llu=EDs?= Batlle i Rossell <viric@viric.name>
Subject: Re: unable to handle paging request, arm, at aio/tcp code, only 3.6
Date: Tue, 20 Nov 2012 07:55:59 +0100
Message-ID: <20121120065559.GA2186@vicerveza.homeunix.net>
References: <20121119183222.GI2068@vicerveza.homeunix.net>
 <1353354095.10798.76.camel@edumazet-glaptop>
 <1353360858.10798.86.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-03-ewr.mailhop.org ([204.13.248.66]:39978 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751379Ab2KTG4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 01:56:10 -0500
Content-Disposition: inline
In-Reply-To: <1353360858.10798.86.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 19, 2012 at 01:34:18PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> > Thanks for the report.
> > 
> > I believe this is a regression of commit
> > 35ad9b9cf7d8a2e6259a0d24022e910adb6f3489
> > (ipv6: Add helper inet6_csk_update_pmtu().)
> > 
> > I'll prepare a patch to fix this.
> 
> Please try the following fix.
> 
> Thanks !

Ok, I'm running it. Let's see if it crashes today.

Thank you!
