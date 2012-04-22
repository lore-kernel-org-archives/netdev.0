From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: Question with secure_ipv4_port_ephemeral() implementation
Date: Sun, 22 Apr 2012 23:38:38 +0900
Message-ID: <201204222338.FHB90661.OFJFOVMFHSOtLQ@I-love.SAKURA.ne.jp>
References: <201204202130.IJF95312.tQJFLMFOFSVHOO@I-love.SAKURA.ne.jp>
	<1335065393.3209.361.camel@deadeye>
	<201204221420.GJB51054.OtHOFSQJFOVMFL@I-love.SAKURA.ne.jp>
	<1335104462.3209.377.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:54569 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504Ab2DVOiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2012 10:38:51 -0400
In-Reply-To: <1335104462.3209.377.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> All this randomisation is concerned with preventing spoofing attacks by
> attackers that can't see any packets routed to the spoofed address.  If
> they can see the return packets then this is all in vain, which is why
> we generally want cryptography at the transport or application level.
> But if they can't then the port offset remains secret - right?
> 
> (Port randomisation is not very useful on it own due to the small number
> space, but see
> <http://en.wikipedia.org/wiki/DNS_cache_poisoning#Prevention_and_mitigation>.)

Thank you. So, this change (which looked to me a regression) is not a regression.
