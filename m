From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next] Re: rib_trie / Fix inflate_threshold_root.
	Now=15 size=11 bits
Date: Wed, 15 Jul 2009 15:05:26 +0200
Message-ID: <20090715130526.GA3082@ami.dom.local>
References: <20090705173208.GB19477@ami.dom.local> <20090705213232.GG8943@linux.vnet.ibm.com> <20090705222301.GA3203@ami.dom.local> <4A513D0D.5070204@itcare.pl> <20090706090207.GB3065@ami.dom.local> <4A53D28D.8060409@itcare.pl> <20090707235029.GA8207@ami.dom.local> <4A565449.4050403@itcare.pl> <20090714194100.GA7952@ami.dom.local> <19037.34959.327456.662899@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	=?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:52230 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZGONFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 09:05:45 -0400
Received: by fxm18 with SMTP id 18so3437493fxm.37
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 06:05:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19037.34959.327456.662899@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2009 at 09:43:11AM +0200, Robert Olsson wrote:
> 
> Jarek Poplawski writes:
> 
> 
> Looks good. Maybe we're getting close to some generic solution to take 
> a very optimistic approach wrt thresholds for root node and adjust to 
> settings without the warning. Or maybe now even remove warning totally
> with stata counter?

I guess, we could, but maybe let's wait a bit to make sure there is
nothing surprising?

> 
> Can we even consider some other different strategy for bumping up the root 
> node. 
> 
> We need all lookup performance we can get when we now try to route without 
> the route cache. And we probably need to evaluate the cost for the multiple 
> lookups again at least for LOCAL and MAIN when we talking routing well at 
> least straight-forward simple routing. (Semantic change)
> 
> I think I've got ~6.2 Gbit/s for simplex forwarding using traffic patterns 
> we see in/close to Internet core. This w/o route cache on our hi-end opterons
> with 8 CPU cores using niu and ixgbe. I'll test again and your patches when
> I'm back from vacation.
> 

Sure, I was mainly aiming at safe defaults (wrt. memory usage), but if
tests show there is a better strategy we should go for it.

Thanks,
Jarek P.
