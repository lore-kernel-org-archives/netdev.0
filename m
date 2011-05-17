From: Rick Jones <rick.jones2@hp.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 14:40:32 -0700
Message-ID: <1305668432.8149.958.camel@tardy>
References: <1305666050.2691.4.camel@edumazet-laptop>
	 <20110517.171000.1166144155994185790.davem@davemloft.net>
	 <1305666822.2848.51.camel@bwh-desktop>
	 <20110517.172630.1789843473242620898.davem@davemloft.net>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:38577 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932457Ab1EQVtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:49:10 -0400
In-Reply-To: <20110517.172630.1789843473242620898.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 17:26 -0400, David Miller wrote:
> The idea to do RFS post fragmentation is interesting, it's sort of
> another form of GRO.  We would need to re-fragment (like GRO does)
> in the forwarding case.
> 
> But it would be nice since it would reduce the number of calls into
> the stack (and thus route lookups, etc.) per fragmented frame.
> 
> There is of course the issue of fragmentation queue timeouts, and
> what semantics of that means when we are not the final destination
> and those fragments would have been forwarded rather than consumed
> by us.

If we are not the final destination, should there be any reassembly
going-on in the first place?

And if reassembly times-out, don't the frags just get dropped like they
would anyway?

Eric keeps asking about (real) workload :)  About the only one I can
think of at this point that would have much in the way of UDP fragments
is EDNS.  Apart from that we may be worrying about how many fragments
can dance on the header of an IP datagram?-)

rick

