From: Bill Fink <billfink@mindspring.com>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Tue, 13 Mar 2012 02:15:29 -0400
Message-ID: <20120313021529.97514922.billfink@mindspring.com>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
	<20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Diego Woitasen <diego@woitasen.com.ar>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:37555 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758136Ab2CMGPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 02:15:42 -0400
In-Reply-To: <20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Mar 2012, Stephen Hemminger wrote:

> On Mon, 12 Mar 2012 22:18:48 -0300
> Diego Woitasen <diego@woitasen.com.ar> wrote:
> 
> > Hi,
> >  I've noticed that iproute and the old route command show the routes
> > in the inverse order. This new behavior looks related to the removal
> > of fib_hash (replaceed by fib_trie). I think that the old behavior
> > should be recovered. More specific routes in the first place looks
> > more natural for me and it's been the behavior for years. It doesn't
> > make any sense to change it.
> > 
> >  Sorry if this was already discussed, I couldn't find anything in the archives.
> > 
> > Regards,
> >  Diego
> > 
> 
> The kerne never guaranteed any order in returned values. If you want a given
> order than you need to sort them your self.

I understand the kernel doesn't guarantee any order to the routes.
But it does make sense for the userspace tools like ip to do this
for the user since the kernel is no longer doing this.  And having
more specific routes first also makes sense.  Some scripts may depend
on this plus its much more efficent that way if trying to find a
matching route since you can quit on the first match instead of
having to scan the entire routing table.

						-Bill
