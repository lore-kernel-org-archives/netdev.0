From: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 20:41:01 +0300
Message-ID: <201005262041.01551.nuclearcat@nuclearcat.com>
References: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com> <AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com> <87fx1e1sat.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:57220 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755929Ab0EZRl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 13:41:26 -0400
In-Reply-To: <87fx1e1sat.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 26 May 2010 20:33:46 Andi Kleen wrote:
> Tom Herbert <therbert@google.com> writes:
> > Thanks to NAT, the concept of a network path or even host specific
> > path is a weakened concept.  On the Internet this may be a path
> > characteristic per client, which unfortunately has no visibility in
> > the kernel other than per connection state.  When a single IP address
> > may have thousands of hosts behind it, caching TCP parameters for that
> > IP address is implicitly doing a huge aggregation-- probably dicey...
> 
> Yes all of Saudi-Arabia used to be (is?) one IP address...
> 
> Caching anything per IP is bogus.
> 
> -Andi
> 
In Lebanon i have around 30k users behind few IP addresses(around 6) (for 
web).
Because backbone here $1200/Mbit, and satellites mostly(rtt 400+ ms)... so TCP 
accelerators and caching proxy a must. Tproxy doesn't work well yet to use 
full set of ip's.

And no local google/youtube servers, so maybe i'm affected by something? :-)
