From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH/RFC net-next] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Mon, 1 Jun 2015 13:25:25 +0900
Message-ID: <20150601042522.GA6026@vergenet.net>
References: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB417A2@AcuExch.aculab.com>
 <CAE4R7bC7qt9LhDqvpb-ZvWB6te=nf4DgXrC0T4NT7DX2yrCgrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35220 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758711AbbFAEZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:25:34 -0400
Received: by pdbnf5 with SMTP id nf5so37087879pdb.2
        for <netdev@vger.kernel.org>; Sun, 31 May 2015 21:25:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bC7qt9LhDqvpb-ZvWB6te=nf4DgXrC0T4NT7DX2yrCgrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 08:53:20AM -0700, Scott Feldman wrote:
> On Thu, May 28, 2015 at 2:18 AM, David Laight <David.Laight@aculab.com> wrote:
> > From: Simon Horman
> >> Sent: 28 May 2015 04:23
> >> The rocker (switch) of a rocker_port may be trivially obtained from
> >> the latter it seems cleaner not to pass the former to a function when
> >> the latter is being passed anyway.
> >
> > If the arguments are passed in registers (they almost certainly are)
> > or the function is inlined (possible since they are static) and
> > the calling code already has both values in registers then
> > passing both values saves a memory read inside the called code.
> >
> > So on 'hot paths' it probably makes sense to pass both values.
> 
> Agreed, and Simon's patch is 99% cold path, so I'd rather trade
> clarity in the code than saving a nanosec in a driver cold path.
> 
> Simon, would you respin, remove rocker_port_rx_proc() changes, remove
> RFC, and add my ack?  rocker_port_rx_proc() was the only hot path case
> I found.

Sure, that seems reasonable to me. I have done so.
