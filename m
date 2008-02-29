From: Sam Ravnborg <sam@ravnborg.org>
Subject: Purpose of __net_exit & friends [Was: [ICMP6]: Consolidate fail ...]
Date: Fri, 29 Feb 2008 21:12:47 +0100
Message-ID: <20080229201247.GA7139@uranus.ravnborg.org>
References: <1204292360.10368.11.camel@iris.sw.ru> <1204292458-11636-12-git-send-email-den@openvz.org> <20080229.112342.76764059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: den@openvz.org, netdev@vger.kernel.org, containers@lists.osdl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:41168 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753505AbYB2UMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 15:12:34 -0500
Content-Disposition: inline
In-Reply-To: <20080229.112342.76764059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 29, 2008 at 11:23:42AM -0800, David Miller wrote:
> From: "Denis V. Lunev" <den@openvz.org>
> Date: Fri, 29 Feb 2008 16:40:58 +0300
> 
> > +static void __net_exit icmpv6_sk_exit(struct net *net)
> > +{
> 
> Since you call this from __new_init code, won't this
> create a section conflict when ipv6 is built statically
> into the kernel?

I have noticed this __net_init/__net_exit stuff before
but never got around to ask about it.

Whats the actual purpose and are there any strict
rules as to what may be called from where?
If there are we should apply the same checks as we do
for __devinit/__devexit and friends.

	Sam
