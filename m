From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bugme-new] [Bug 32832] New: shutdown(2) does not fully shut
 down socket any more
Date: Wed, 13 Apr 2011 11:47:09 -0700
Message-ID: <20110413114709.32f5931e@nehalam>
References: <1302663327.2811.55.camel@edumazet-laptop>
	<1302663608.2811.62.camel@edumazet-laptop>
	<BANLkTi=1wmQYRgHmO5SbPBiSwzKwVz4_ag@mail.gmail.com>
	<20110413.104317.71110417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dbaluta@ixiacom.com, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kees@outflux.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38709 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756652Ab1DMSrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 14:47:12 -0400
In-Reply-To: <20110413.104317.71110417.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Apr 2011 10:43:17 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Daniel Baluta <dbaluta@ixiacom.com>
> Date: Wed, 13 Apr 2011 14:57:18 +0300
> 
> > Cyril's use case looks suspect. I don't think that this is a good
> > reason for reverting this commit.
> 
> I complete disagree.
> 
> Something that worked perfectly fine, probably for years, we broke.
> 
> We simply cannot do that, especially since we do not have a reasonable
> alternative at this time.
> 
> Adding SO_REUSEPORT is a long range option, and not something that
> will provide a fix for users right now.
> 
> So please don't even pretend to suggest that we shouldn't fix this
> with a revert unless a simple, obvious, kernel fix presents itself.

Just to echo what Dave said.
Even though the semantics of this is not documented in some standard,
applications have been built on Linux expecting a certain behavior.
If you want to change what happens in this case, you have to have a
really good reason (like crash, security hole, or standards violation).
