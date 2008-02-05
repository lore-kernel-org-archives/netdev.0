From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 17:48:37 +0100
Message-ID: <20080205164837.GC23145@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <20080205154213.059ac6e8@core> <20080205163912.GB23145@one.firstfloor.org> <20080205160301.7b2369ee@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:36637 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbYBEQNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 11:13:45 -0500
Content-Disposition: inline
In-Reply-To: <20080205160301.7b2369ee@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 04:03:01PM +0000, Alan Cox wrote:
> > Also your sub PC class appliances rarely run LISTEN servers anyways
> > that are open to the world.
> 
> Really. The ones that first come to mind often have exposed ports
> including PDA devices and phones. (Ditto low end PC boxes - portscan an
> EEPC some day ;))

What kind of LISTEN ports? And does it matter if they're DoS'ed?

The only one I can think of right now would be ident and frankly nobody
will really care if that one works or not.

If it's just the management interface etc. (which should really be firewalled) 
then likely not.


> Is the other stuff enough - good question, and can be measured easily
> enough on a little dlink router or similar.

My guess would be that it is.

If it's not it would be probably better to look at improving the standard queue 
management again; e.g.readd RED.

-Andi

