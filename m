From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix the fib trie iterator to work with a single
 entry routing tables
Date: Fri, 26 Jan 2007 19:06:34 -0800 (PST)
Message-ID: <20070126.190634.85416088.davem@davemloft.net>
References: <20070124.144254.78492493.davem@davemloft.net>
	<17849.64125.710251.587076@robur.slu.se>
	<m1veitvlpa.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51832
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752158AbXA0DGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 22:06:34 -0500
In-Reply-To: <m1veitvlpa.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 26 Jan 2007 08:42:25 -0700

> Robert Olsson <Robert.Olsson@data.slu.se> writes:
> 
> > David Miller writes:
> >
> >  > > Yes the case when the trie is just a single leaf got wrong with the
> >  > > iterator and your patchs cures it. I think we have a similar problem
> >  > > with /proc/net/fib_trie
> >  > 
> >  > I'm happy to review a fix for that :-)
> >  
> > When main table is just a single leaf this gets printed as belonging to the 
> > local table in /proc/net/fib_trie. A fix is below.
> 
> Good spotting.  I was happy the data was showing up, I missed we that we put
> the meta information was wrong.
> 
> Looks good to me.

To me too, applied.

Thanks!
