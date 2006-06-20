From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 02:54:36 +0200
Message-ID: <4497474C.4050706@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain> <1150286766.5233.15.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@comx.dk>, hawk@diku.dk,
	russell-tcatm@stuart.id.au, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:12536 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965024AbWFTAzY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 20:55:24 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150286766.5233.15.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> - For further reflection: Have you considered the case where the rate
> table has already been considered on some link speed in user space and
> then somewhere post-config the physical link speed changes? This would
> happen in the case where ethernet AN is involved and the partner makes
> some changes (use ethtool). 
> 
> I would say the last bullet is a more interesting problem than a corner
> case of some link layer technology that has high overhead.
> Your work would be more interesting if it was generic for many link
> layers instead of just ATM.

I've thought about this a couple of times, scaling the virtual clock
rate should be enough for "simple" qdiscs like TBF or HTB, which have
a linear relation between time and bandwidth. I haven't really thought
about the effects on HFSC yet, on a small scale the relation is
non-linear. But this is a different problem from trying to accomodate
for link-layer overhead.
