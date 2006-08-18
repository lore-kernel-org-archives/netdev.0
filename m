From: Michael Buesch <mb@bu3sch.de>
Subject: Re: proposal for new wireless configuration API
Date: Sat, 19 Aug 2006 00:02:42 +0200
Message-ID: <200608190002.42436.mb@bu3sch.de>
References: <1155655728.17742.30.camel@ux156> <1155885125.3425.11.camel@ux156> <20060818212941.GB28711@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:44236
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751509AbWHRWDU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 18:03:20 -0400
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <20060818212941.GB28711@p15091797.pureserver.info>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 18 August 2006 23:29, Ulrich Kunitz wrote:
> On 06-08-18 09:12 Johannes Berg wrote:
> 
> > On Fri, 2006-08-18 at 01:29 +0200, Ulrich Kunitz wrote:
> > > Or are here people, who
> > > really want to freely transmit on all frequencies their RF might
> > > be able to generate?
> > 
> > Yes :P
> > Some amateur radio people asked me about extending the spectrum a bit to
> > the top (apparently they're allowed to use the band just above the ISM
> > band as well).
> 
> I had some discussions with radio amateurs about the RFs in the
> ZD1211 devices. Even if I could transmit in their required bands,
> the RFs are so WLAN specific, that they don't fulfill their
> requirements. It's really funny, if somebody explains to you that
> these chips are of extremely low quality. I always try to explain
> to them that the complete devices are sold for only 17 Euros
> including VAT. You cannot expect for this price the quality
> required for long range transmissions at these high frequencies.
> 
> I support the idea that radio amateurs should create their own
> patches if they need it. Supporting the frequencies in the
> interface, is a typical feature used by less than 1% of the user
> base, but would cost more than 80% of the effort. We should also not
> do anything, which would raise the impression, that we want to
> ignore regulatory rules.

I second that.
We should not allow to drive devices outside of the specs.
If someone wants to do this, he should be able to apply a one-liner
patch to tune to some different frequency. ;)

> > However, I don't think we need to cater them in the API. I think they
> > ought to be able to live with kernel patches since we don't really know
> > how far up the frequency on say the bcm43xx can go anyway before the
> > card breaks/malfunctions.
> 
> Do they have a separate RF? They data sheets are usually
> available, even if the not always explain the register
> programming.

We currently know 6 different radio chips used by bcm43xx:
http://bcm-specs.sipsolutions.net/RadioID

AFAIK the chip is from broadcom, too. I don't like to check
now, as that would require to disassemble my AP and look at
the chip. ;) But I'm pretty sure.
There is no datasheet available for the chip. At least nobody
was able to get or found one so far... .

-- 
Greetings Michael.
