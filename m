From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Thu, 18 Mar 2010 14:04:24 -0700
Message-ID: <20100318140424.aaf3ec24.akpm@linux-foundation.org>
References: <4AE92F4D.6070101@gmail.com>
	<20091029.010009.175904855.davem@davemloft.net>
	<alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi>
	<20091202.222446.10943991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, eric.dumazet@gmail.com,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	kolo@albatani.cz, bugzilla-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54166 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401Ab0CRVFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 17:05:51 -0400
In-Reply-To: <20091202.222446.10943991.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 02 Dec 2009 22:24:46 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: "Ilpo J__rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 26 Nov 2009 23:54:53 +0200 (EET)
> 
> > [PATCH] tcp: clear hints to avoid a stale one (nfs only affected?)
> 
> Ok, since Linus just released 2.6.32 I'm tossing this into net-next-2.6
> so it gets wider exposure.
> 
> I still want to see test results from the bug reporter, and if it fixes
> things we can toss this into -stable too.

Despite my request to take this to email, quite a few people have been
jumping onto this report via bugzilla:
http://bugzilla.kernel.org/show_bug.cgi?id=14470

Bit of a pita, but it'd be worth someone taking a look to ensure that
we're all talking about the same bug.

