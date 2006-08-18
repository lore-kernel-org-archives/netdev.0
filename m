From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 09:12:05 +0200
Message-ID: <1155885125.3425.11.camel@ux156>
References: <1155655728.17742.30.camel@ux156>
	 <1155659387.3005.15.camel@localhost.localdomain>
	 <200608151838.58182.mb@bu3sch.de>
	 <20060817232941.GB23163@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:63149 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750794AbWHRHLh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 03:11:37 -0400
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20060817232941.GB23163@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-18 at 01:29 +0200, Ulrich Kunitz wrote:
> Or are here people, who
> really want to freely transmit on all frequencies their RF might
> be able to generate?

Yes :P
Some amateur radio people asked me about extending the spectrum a bit to
the top (apparently they're allowed to use the band just above the ISM
band as well).

However, I don't think we need to cater them in the API. I think they
ought to be able to live with kernel patches since we don't really know
how far up the frequency on say the bcm43xx can go anyway before the
card breaks/malfunctions.

johannes
