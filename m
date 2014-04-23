From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Wed, 23 Apr 2014 17:30:18 +0200
Message-ID: <20140423153018.GA13717@breakpoint.cc>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34731 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754223AbaDWPaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 11:30:19 -0400
Content-Disposition: inline
In-Reply-To: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> wrote:
> ICMP ping sockets currently require a new ping binary and are only
> available after setting a sysctl.  The code adds about 10K to the
> (uncompressed) size of the kernel.  Make this optional and disable
> it by default.
> 
> This is compile-tested only; I'd just like to see whether people think
> this is worth doing.

Either this feature needs to be ripped out now or it has to be kept.

I do not think the middle-ground you're proposing will work:

If userspace cannot safely assume facility is available, binaries
need to be setuid to implement fallback, and when you go down that
road you've gained nothing and might as well not support ping sockets
at all.
