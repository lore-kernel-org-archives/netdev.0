From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] ipv4/ipv6: check hop limit field on input
Date: Mon, 1 Jun 2009 19:13:40 +0200
Message-ID: <20090601171340.GB29745@Chamillionaire.breakpoint.cc>
References: <4A23F027.3060907@dev.6wind.com> <20090601161917.GA29745@Chamillionaire.breakpoint.cc> <4A240681.2010300@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:38577 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750871AbZFARNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2009 13:13:39 -0400
Content-Disposition: inline
In-Reply-To: <4A240681.2010300@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>> Whats wrong with the checks in ip(6)_forward?
> It's on forward, not on input. Router must not process it.
> For example, if you try to ping (with ttl set to 0) the router, you will 
> receive a reply.

Ah.  That makes more sense.
However, I'd argue that this is sane behaviour.

The datagram did reach its intended destination and the TTL did not
"exceed in transit" (if it had, the datagram would not have been
received).  Why discard an otherwise perfectly legal packet?
