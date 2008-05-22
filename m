From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] net: neighbour table ABI problem
Date: Thu, 22 May 2008 02:20:42 +0200
Message-ID: <20080522002042.GO20815@postel.suug.ch>
References: <20080521163815.GA5028@sc.homeunix.net> <4834544A.4010706@trash.net> <20080521104019.22f9c712@extreme> <20080521.133510.145260976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, kaber@trash.net, Stephane_Chazelas@yahoo.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49677 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759207AbYEVAUW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 20:20:22 -0400
Content-Disposition: inline
In-Reply-To: <20080521.133510.145260976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> 2008-05-21 13:35
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 21 May 2008 10:40:19 -0700
> 
> > This change is small, but it breaks the ABI for older version of iproute2 utilities.
> > But these utilities are already broken since they are looking at the psched_hz values
> > which are completely different. So let's just go ahead and fix both kernel and user
> > space. Older utilities will just print wrong values.
> > 
> 
> Can we add a new attribute or something like that?

We could do but I agree with Stephen to just fix it the way he
proposes. The value we're talking is only useful in a debugging
or statistical context. We're not changing the format of the
attribute at all, not even the unit, srictly speaking.
