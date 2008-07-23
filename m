From: Alex Davis <alex14641@yahoo.com>
Subject: Re: sleeping in irq context in match()
Date: Wed, 23 Jul 2008 13:29:45 -0700 (PDT)
Message-ID: <486649.55257.qm@web50203.mail.re2.yahoo.com>
References: <20080723191443.GT10471@solarflare.com>
Reply-To: alex14641@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50203.mail.re2.yahoo.com ([206.190.38.44]:44175 "HELO
	web50203.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753710AbYGWUg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 16:36:27 -0400
In-Reply-To: <20080723191443.GT10471@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Wed, 7/23/08, Ben Hutchings <bhutchings@solarflare.com> wrote:

> From: Ben Hutchings <bhutchings@solarflare.com>
> Subject: Re: sleeping in irq context in match()
> To: "Arjan van de Ven" <arjan@infradead.org>
> Cc: "Alex Davis" <alex14641@yahoo.com>, netdev@vger.kernel.org
> Date: Wednesday, July 23, 2008, 3:14 PM
> Arjan van de Ven wrote:
> > Hi,
> > 
> > the backtrace below is popping up in kerneloops.org
> stats pretty
> > quickly; I don't know if it's been discussed
> here before but
> > just wanted to mention it in case it hasn't been..
> > (it's rank 13 right now, out of nowhere)
> > 
> > http://www.kerneloops.org/searchweek.php?search=match 
> for more info
> > 
> > 
> > __might_sleep
> > mutex_lock_nested
> > rtnl_lock
> > *match
> [...]
> 
> Looking at the "more info", I see that that
> function is in xt_ipisforif,
> which is an out-of-tree module.  The author appears to be
> Alex Davis <alex14641@yahoo.com>.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Communications
> Not speaking for my employer; that's the marketing
> department's job.
My goodness!! Someone is actually using it?? I sumbitted the code back in June '06, but it was rejected by Patrick McHardy. I think his words 
were something along the lines of 'I don't want to create a new match 
just for this'. Anyway, I'm still using it on a 2.6.18 kernel. Since
people are using it, I'll consider fixing it to work on later kernels.

Is this something the netfilter team would have an interest in?

I code, therefore I am


      
