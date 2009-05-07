From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [RFC] iproute2/tc caching proposal
Date: Thu, 7 May 2009 22:49:27 +0300
Message-ID: <200905072249.27384.denys@visp.net.lb>
References: <200905070103.37956.denys@visp.net.lb> <4A032C24.7060709@gmail.com> <4A033606.3030400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:41409 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbZEGTti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 15:49:38 -0400
In-Reply-To: <4A033606.3030400@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 May 2009 22:27:02 Jarek Poplawski wrote:
> Jarek Poplawski wrote, On 05/07/2009 08:44 PM:
> > Do you mean 30 sec. is to short for a change? I don't know these things
> > enough; your idea looks very nice, but I wonder if you tested how it
> > behaves if e.g. after 15k rules some dev goes away which is used in the
> > next 15k?
>
> Hmm... actually, it seems there should be no problem, except less info on
> the
>
> reason of the failure.
Info will be same, completely. Just case with changing interfaces have to be 
handled correctly in any case, in case of batch. It is difficult to explain, 
each person doing his own way shapers. I can explain even, why in my case 
caching is better. And probably all other, properly done shapers for such 
cases.

But for me critical, that when i load shaper, machine is for 10 minutes eating 
dust (cpu utilisation is high, fans turning like hell :-))) ), and some of 
users have bandwidth without restrictions. 30 secs much better, and still 
here is space for improvement.


>
>
> Jarek P.


