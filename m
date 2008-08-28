From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 10:45:03 +1000
Message-ID: <200808281045.03460.nickpiggin@yahoo.com.au>
References: <87vdxmr53f.fsf@basil.nowhere.org> <20080827.151824.14173512.davem@davemloft.net> <20080827223952.GE26610@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	johnpol@2ka.mipt.ru, dada1@cosmosbay.com, denys@visp.net.lb,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.mail.mud.yahoo.com ([209.191.84.164]:32214 "HELO
	smtp115.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754049AbYH1ApM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 20:45:12 -0400
In-Reply-To: <20080827223952.GE26610@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008 08:39, Andi Kleen wrote:
> On Wed, Aug 27, 2008 at 03:18:24PM -0700, David Miller wrote:
> > From: Andi Kleen <andi@firstfloor.org>
> > Date: Wed, 27 Aug 2008 18:27:35 +0200
> >
> > > > Those banks really want to crank down on latency - to the point they
> > > > start disabling interrupt coalescing.  I bet they'd toss anything out
> > > > they could to shave another microsecond.
> > >
> > > This change would actually likely lower their latency.
> >
> > They want the timestamps, but they want it to match when the packet
> > arrived at their system as closely as is reasonably possible.
>
> Then they should use hardware time stamps which are increasingly
> available (e.g. current Intel e1000 design has them and I expect
> others too).

Would it make sense to make a new option for these socket timestamps
and encourage some apps move over to it?
