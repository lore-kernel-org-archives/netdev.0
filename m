From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bug 14470] New: freez in TCP stack
Date: Fri, 19 Mar 2010 17:52:11 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1003191750500.2350@melkinpaasi.cs.helsinki.fi>
References: <4AE92F4D.6070101@gmail.com> <20091029.010009.175904855.davem@davemloft.net> <alpine.DEB.2.00.0911262352050.24189@melkinpaasi.cs.helsinki.fi> <20091202.222446.10943991.davem@davemloft.net> <20100318140424.aaf3ec24.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>, kolo@albatani.cz,
	bugzilla-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46346 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0CSPwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 11:52:12 -0400
In-Reply-To: <20100318140424.aaf3ec24.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Mar 2010, Andrew Morton wrote:

> On Wed, 02 Dec 2009 22:24:46 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: "Ilpo J__rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Thu, 26 Nov 2009 23:54:53 +0200 (EET)
> > 
> > > [PATCH] tcp: clear hints to avoid a stale one (nfs only affected?)
> > 
> > Ok, since Linus just released 2.6.32 I'm tossing this into net-next-2.6
> > so it gets wider exposure.
> > 
> > I still want to see test results from the bug reporter, and if it fixes
> > things we can toss this into -stable too.
> 
> Despite my request to take this to email, quite a few people have been
> jumping onto this report via bugzilla:
> http://bugzilla.kernel.org/show_bug.cgi?id=14470
> 
> Bit of a pita, but it'd be worth someone taking a look to ensure that
> we're all talking about the same bug.

Could one try with this debug patch:

http://marc.info/?l=linux-kernel&m=126624014117610&w=2

It should prevent crashing too.

-- 
 i.
