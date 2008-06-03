From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: neighbour table ABI problem
Date: Tue, 03 Jun 2008 16:03:27 -0700 (PDT)
Message-ID: <20080603.160327.105786253.davem@davemloft.net>
References: <20080521104019.22f9c712@extreme>
	<20080521.133510.145260976.davem@davemloft.net>
	<20080522002042.GO20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, kaber@trash.net, Stephane_Chazelas@yahoo.fr,
	netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55216
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753001AbYFCXD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:03:28 -0400
In-Reply-To: <20080522002042.GO20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 22 May 2008 02:20:42 +0200

> * David Miller <davem@davemloft.net> 2008-05-21 13:35
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Wed, 21 May 2008 10:40:19 -0700
> > 
> > > This change is small, but it breaks the ABI for older version of iproute2 utilities.
> > > But these utilities are already broken since they are looking at the psched_hz values
> > > which are completely different. So let's just go ahead and fix both kernel and user
> > > space. Older utilities will just print wrong values.
> > > 
> > 
> > Can we add a new attribute or something like that?
> 
> We could do but I agree with Stephen to just fix it the way he
> proposes. The value we're talking is only useful in a debugging
> or statistical context. We're not changing the format of the
> attribute at all, not even the unit, srictly speaking.

Fair enough, I've applied Stephen's patch.

Thanks.
