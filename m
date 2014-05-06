From: josh@joshtriplett.org
Subject: Re: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Tue, 6 May 2014 10:30:15 -0700
Message-ID: <20140506173015.GC20776@cloud>
References: <1399328773-6531-9-git-send-email-andi@firstfloor.org>
 <20140505.231229.136734008603421707.davem@davemloft.net>
 <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <1399394359.15399.20.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140506164546.GB20536@cloud>
 <1399395804.15399.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:34717 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750748AbaEFRaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:30:20 -0400
Content-Disposition: inline
In-Reply-To: <1399395804.15399.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 06, 2014 at 10:03:24AM -0700, Eric Dumazet wrote:
> On Tue, 2014-05-06 at 09:45 -0700, josh@joshtriplett.org wrote:
> 
> > Sounds like we have some optimization to do, then; there's no
> > fundamental unfixable reason for that delta.
> 
> I think you have little idea of the reasons for this delta.

I have a rather good idea, actually.

> Some servers handle 10 millions of TCP flows, using as little as 1KB per
> connection in user space, all included.
> 
> Do you have an idea of how much memory is needed for 10 millions TCP
> sockets in the kernel ?

Too much.  That's potentially fixable, but not if we start with the
premise that it's impossible.

- Josh Triplett
