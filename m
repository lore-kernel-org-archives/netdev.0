From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: proposal for new wireless configuration API
Date: Fri, 18 Aug 2006 23:29:41 +0200
Message-ID: <20060818212941.GB28711@p15091797.pureserver.info>
References: <1155655728.17742.30.camel@ux156> <1155659387.3005.15.camel@localhost.localdomain> <200608151838.58182.mb@bu3sch.de> <20060817232941.GB23163@p15091797.pureserver.info> <1155885125.3425.11.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:21490 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1751496AbWHRV3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 17:29:42 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <1155885125.3425.11.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-08-18 09:12 Johannes Berg wrote:

> On Fri, 2006-08-18 at 01:29 +0200, Ulrich Kunitz wrote:
> > Or are here people, who
> > really want to freely transmit on all frequencies their RF might
> > be able to generate?
> 
> Yes :P
> Some amateur radio people asked me about extending the spectrum a bit to
> the top (apparently they're allowed to use the band just above the ISM
> band as well).

I had some discussions with radio amateurs about the RFs in the
ZD1211 devices. Even if I could transmit in their required bands,
the RFs are so WLAN specific, that they don't fulfill their
requirements. It's really funny, if somebody explains to you that
these chips are of extremely low quality. I always try to explain
to them that the complete devices are sold for only 17 Euros
including VAT. You cannot expect for this price the quality
required for long range transmissions at these high frequencies.

I support the idea that radio amateurs should create their own
patches if they need it. Supporting the frequencies in the
interface, is a typical feature used by less than 1% of the user
base, but would cost more than 80% of the effort. We should also not
do anything, which would raise the impression, that we want to
ignore regulatory rules.

> However, I don't think we need to cater them in the API. I think they
> ought to be able to live with kernel patches since we don't really know
> how far up the frequency on say the bcm43xx can go anyway before the
> card breaks/malfunctions.

Do they have a separate RF? They data sheets are usually
available, even if the not always explain the register
programming.

-- 
Uli Kunitz
