From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Thu, 24 Apr 2014 17:17:48 +0200
Message-ID: <20140424151748.GH1960@order.stressinduktion.org>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk> <20140423153018.GA13717@breakpoint.cc> <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk> <20140423162712.GB13717@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37077 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbaDXPRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:17:49 -0400
Content-Disposition: inline
In-Reply-To: <20140423162712.GB13717@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 06:27:12PM +0200, Florian Westphal wrote:
> Ben Hutchings <ben@decadent.org.uk> wrote:
> > Userspace can't assume it now because access is controlled by a sysctl.
> > 
> > I think it is for distributions to choose whether to enable this feature
> > in ping and the kernel.
> 
> I am not (yet) buying this argument.
> 
> Saying 'you need to change sysctl foo for this to work' in a program manpage
> is a lot different than 'you need to recompile the kernel'.

Maybe we can make the Kconfig option depend on CONFIG_EMBEDDED so that we can
be sure people don't have man-pages on the device. ;)

Seriously, I think doing authorization check based on gids in a sysctl is
wrong. Switching over to capabilities seems to make this interface much
more useable to me. But we would need to make sure, that we don't suddenly
allow people to use those sockets where it was restricted previously.

Greetings,

  Hannes
