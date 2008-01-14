From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/9] get rid of unused revision element
Date: Mon, 14 Jan 2008 08:35:55 -0800
Message-ID: <20080114083555.48792f6b@deepthought>
References: <20080112064646.132747871@linux-foundation.org>
	<20080112.205059.223738374.davem@davemloft.net>
	<18315.19232.437801.553809@robur.slu.se>
	<20080114.040657.117757802.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55298 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYANQjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 11:39:33 -0500
In-Reply-To: <20080114.040657.117757802.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Jan 2008 04:06:57 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Robert Olsson <Robert.Olsson@data.slu.se>
> Date: Mon, 14 Jan 2008 12:44:32 +0100
> 
> >  The idea was to have a selective flush of route cache entries when
> >  a fib insert/delete happened. From what I remember you added another/
> >  better solution. Just a list with route cache entries pointing to parent 
> >  route. So yes this was obsoleted by your/our effort to avoid total 
> >  flushing of the route cache. Unfinished work.
> 
> Yes, that's right.  The synchronization was very hard.
> 
> But there is another issue, see below....
> 
> >  According to  http://bgpupdates.potaroo.net/instability/bgpupd.html
> >  (last in page) we currently flush the route cache 2.80 times per second. 
> >  when using full Internet routing with Linux. Maybe we're forced to pick 
> >  up this thread again someday.
> 
> This proves we need to solve this problem.
> 
> The reason I've never gone back to that work is that I didn't
> want to do it while we still had multiple FIB data structure
> implementations.
> 
> Someone needs to go over whatever deficiencies exist in fib_trie
> vs. fib_hash so that we can delete fib_hash and move over to using
> fib_trie always.  It makes no sense to implement everything
> interfacing into that code twice.
> 
> There was a full consensus that this was the way to move forward,
> we just need the dirty work to be done.
> 
> If someone wants to show their gratitude for my getting rid of
> the multipath cached routing code, the above work would be a
> great way to do so (hint hint) :-)

I will be glad to get this working.  Is there any point in doing the a
small systems version as well?

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
