From: jamal <hadi@cyberus.ca>
Subject: Re: bk16 changes to cbq
Date: 05 Jul 2004 21:28:09 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089077288.1068.5.camel@jzny.localdomain>
References: <1088861810.1039.298.camel@jzny.localdomain>
	 <20040705202727.GA21226@ms2.inr.ac.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20040705202727.GA21226@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2004-07-05 at 16:27, Alexey Kuznetsov wrote:
> Hello!
> 
> > What i remember is this (4-5 years back) used to cure a bug - cant
> > remember the details unfortunately, but Alexey may remember.
> 
> Actually, I do not. It looks like an optimization: if the device is
> throttled we just do not need to add timer, qdisc will be woken up
> by unthrottle. I do not see any race condition here, but also I do not
> see why this check could be important.

Indeed it looks like an optimization; instead of two events (queue
watchdog and probably EOL )or device wdog) trying to reschedule device,
only one does.
 
> > At the expense of repeating a discussion that may have already happened,
> 
> To be honest, I wish to be reminded. If this check cured something,
> it would be interesting to know what was this.

I searched the archives couldnt find anything relevant. 

cheers,
jamal
