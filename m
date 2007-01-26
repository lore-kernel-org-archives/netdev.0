From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Fix the fib trie iterator to work with a single entry routing tables
Date: Fri, 26 Jan 2007 08:42:25 -0700
Message-ID: <m1veitvlpa.fsf@ebiederm.dsl.xmission.com>
References: <m17ivc19na.fsf@ebiederm.dsl.xmission.com>
	<17847.54018.72176.431127@robur.slu.se>
	<20070124.144254.78492493.davem@davemloft.net>
	<17849.64125.710251.587076@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:40634 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030691AbXAZPnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 10:43:00 -0500
In-Reply-To: <17849.64125.710251.587076@robur.slu.se> (Robert Olsson's message
	of "Fri, 26 Jan 2007 13:56:29 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Olsson <Robert.Olsson@data.slu.se> writes:

> David Miller writes:
>
>  > > Yes the case when the trie is just a single leaf got wrong with the
>  > > iterator and your patchs cures it. I think we have a similar problem
>  > > with /proc/net/fib_trie
>  > 
>  > I'm happy to review a fix for that :-)
>  
> When main table is just a single leaf this gets printed as belonging to the 
> local table in /proc/net/fib_trie. A fix is below.

Good spotting.  I was happy the data was showing up, I missed we that we put
the meta information was wrong.

Looks good to me.

Eric
