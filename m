From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] iproute2/tc caching proposal
Date: Thu, 7 May 2009 22:01:56 +0200
Message-ID: <20090507200156.GA3184@ami.dom.local>
References: <200905070103.37956.denys@visp.net.lb> <4A032C24.7060709@gmail.com> <4A033606.3030400@gmail.com> <200905072249.27384.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:53969 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbZEGUDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 16:03:30 -0400
Received: by fxm2 with SMTP id 2so1009759fxm.37
        for <netdev@vger.kernel.org>; Thu, 07 May 2009 13:03:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200905072249.27384.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 07, 2009 at 10:49:27PM +0300, Denys Fedoryschenko wrote:
> On Thursday 07 May 2009 22:27:02 Jarek Poplawski wrote:
> > Jarek Poplawski wrote, On 05/07/2009 08:44 PM:
> > > Do you mean 30 sec. is to short for a change? I don't know these things
> > > enough; your idea looks very nice, but I wonder if you tested how it
> > > behaves if e.g. after 15k rules some dev goes away which is used in the
> > > next 15k?
> >
> > Hmm... actually, it seems there should be no problem, except less info on
> > the
> >
> > reason of the failure.
> Info will be same, completely. Just case with changing interfaces have to be 

If a device was removed you wouldn't get e.g. "Cannot find device ..."
from mirred, I guess.

> handled correctly in any case, in case of batch. It is difficult to explain, 
> each person doing his own way shapers. I can explain even, why in my case 
> caching is better. And probably all other, properly done shapers for such 
> cases.
> 
> But for me critical, that when i load shaper, machine is for 10 minutes eating 
> dust (cpu utilisation is high, fans turning like hell :-))) ), and some of 
> users have bandwidth without restrictions. 30 secs much better, and still 
> here is space for improvement.

I agree the gains look very atractive here.

Jarek P.
