From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net, wireless: Don't return uninitialized in
 __cfg80211_stop_sched_scan()
Date: Wed, 29 Jun 2011 22:55:40 +0200
Message-ID: <1309380940.4071.8.camel@jlt3.sipsolutions.net>
References: <alpine.LNX.2.00.1106292212110.3747@swampdragon.chaosbits.net>
	 <1309379244.4071.7.camel@jlt3.sipsolutions.net>
	 <1309379630.1514.122.camel@cumari>
	 <alpine.LNX.2.00.1106292241230.3747@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Luciano Coelho <coelho@ti.com>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56910 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752411Ab1F2Uzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 16:55:43 -0400
In-Reply-To: <alpine.LNX.2.00.1106292241230.3747@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-29 at 22:42 +0200, Jesper Juhl wrote:
> On Wed, 29 Jun 2011, Luciano Coelho wrote:
> 
> > On Wed, 2011-06-29 at 22:27 +0200, Johannes Berg wrote: 
> > > On Wed, 2011-06-29 at 22:13 +0200, Jesper Juhl wrote:
> > > > If the 'driver_initiated' function argument to
> > > > __cfg80211_stop_sched_scan() is not 0 then we'll return an
> > > > uninitialized 'ret' from the function.
> > > 
> > > 'err'. I also dislike the initialisation, can we just replace the
> > > "return err;" at the end of the function with "return 0;" instead?
> > 
> > Luckily we were never using the return value when passing
> > driver_initiate =- false.
> > 
> > And I agree with you, there's no use to return err at the end.  Better
> > to simply return 0.
> > 
> Ok, so how about this?

Fine with me.

johannes


