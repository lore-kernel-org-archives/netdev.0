From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 11:00:17 -0400
Message-ID: <20060818150006.GA5359@tuxdriver.com>
References: <1155655728.17742.30.camel@ux156> <1155659387.3005.15.camel@localhost.localdomain> <200608151838.58182.mb@bu3sch.de> <20060817232941.GB23163@p15091797.pureserver.info> <1155885125.3425.11.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Kunitz <kune@deine-taler.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:6152 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030465AbWHRPBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 11:01:13 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1155885125.3425.11.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 18, 2006 at 09:12:05AM +0200, Johannes Berg wrote:
> On Fri, 2006-08-18 at 01:29 +0200, Ulrich Kunitz wrote:
> > Or are here people, who
> > really want to freely transmit on all frequencies their RF might
> > be able to generate?
> 
> Yes :P
> Some amateur radio people asked me about extending the spectrum a bit to
> the top (apparently they're allowed to use the band just above the ISM
> band as well).
> 
> However, I don't think we need to cater them in the API. I think they
> ought to be able to live with kernel patches since we don't really know
> how far up the frequency on say the bcm43xx can go anyway before the
> card breaks/malfunctions.

I concur.  It would be best to confine the "normal" API to things
that are legitimately done without a license if at all possible.
Those who are licensed for other spectrum uses should be more than
capable of applying a patch to do so (thereby more clearly taking
regulatory responsibility upon themselves).

John
-- 
John W. Linville
linville@tuxdriver.com
