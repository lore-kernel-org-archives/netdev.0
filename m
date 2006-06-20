From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 10:56:15 -0400
Message-ID: <1150815375.5270.78.camel@jzny2>
References: <1150278004.26181.35.camel@localhost.localdomain>
	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl, russell-tcatm@stuart.id.au, hawk@diku.dk,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:30121 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1751127AbWFTO4T
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 10:56:19 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FsheQ-0005Wg-BB
	for netdev@vger.kernel.org; Tue, 20 Jun 2006 10:56:22 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4497474C.4050706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-20-06 at 02:54 +0200, Patrick McHardy wrote:
> jamal wrote:
> > - For further reflection: Have you considered the case where the rate
> > table has already been considered on some link speed in user space and
> > then somewhere post-config the physical link speed changes? This would
> > happen in the case where ethernet AN is involved and the partner makes
> > some changes (use ethtool). 
> > 
[..]
> I've thought about this a couple of times, scaling the virtual clock
> rate should be enough for "simple" qdiscs like TBF or HTB, which have
> a linear relation between time and bandwidth. I haven't really thought
> about the effects on HFSC yet, on a small scale the relation is
> non-linear. 

Does HFSC not depend on bandwith? How is rate control achieved?

> But this is a different problem from trying to accomodate
> for link-layer overhead.
> 

Yes it is different issue.

cheers,
jamal

