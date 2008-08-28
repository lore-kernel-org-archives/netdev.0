From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 11:07:20 +1000
Message-ID: <200808281107.21173.nickpiggin@yahoo.com.au>
References: <20080827.151824.14173512.davem@davemloft.net> <200808281045.03460.nickpiggin@yahoo.com.au> <20080827.174855.126675086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, rick.jones2@hp.com, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, denys@visp.net.lb, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp103.mail.mud.yahoo.com ([209.191.85.213]:20153 "HELO
	smtp103.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752809AbYH1BH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 21:07:29 -0400
In-Reply-To: <20080827.174855.126675086.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008 10:48, David Miller wrote:
> From: Nick Piggin <nickpiggin@yahoo.com.au>
> Date: Thu, 28 Aug 2008 10:45:03 +1000
>
> > On Thursday 28 August 2008 08:39, Andi Kleen wrote:
> > > On Wed, Aug 27, 2008 at 03:18:24PM -0700, David Miller wrote:
> > > > From: Andi Kleen <andi@firstfloor.org>
> > > > Date: Wed, 27 Aug 2008 18:27:35 +0200
> > > >
> > > > > > Those banks really want to crank down on latency - to the point
> > > > > > they start disabling interrupt coalescing.  I bet they'd toss
> > > > > > anything out they could to shave another microsecond.
> > > > >
> > > > > This change would actually likely lower their latency.
> > > >
> > > > They want the timestamps, but they want it to match when the packet
> > > > arrived at their system as closely as is reasonably possible.
> > >
> > > Then they should use hardware time stamps which are increasingly
> > > available (e.g. current Intel e1000 design has them and I expect
> > > others too).
> >
> > Would it make sense to make a new option for these socket timestamps
> > and encourage some apps move over to it?
>
> We don't have support to using these specific hardware provided timestamps
> sources yet, so it's kind of premature to recommend the facility to
> applications. :)

Dang, that was a really badly quoted. I was reading the thread and
got to the end and just fired off my reply from there...

Sorry -- what I meant to ask was, would it make sense to have a new
option to enable time stamp measuring in the socket receive layer
as in the patchset that Andi referenced, but without removing existing
support for early timestamping?

