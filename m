From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC][PATCH] IP: Make ping sockets optional
Date: Wed, 23 Apr 2014 18:27:12 +0200
Message-ID: <20140423162712.GB13717@breakpoint.cc>
References: <1398266428.7767.140.camel@deadeye.wl.decadent.org.uk>
 <20140423153018.GA13717@breakpoint.cc>
 <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34907 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752680AbaDWQ1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:27:14 -0400
Content-Disposition: inline
In-Reply-To: <1398268542.7767.145.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> wrote:
> Userspace can't assume it now because access is controlled by a sysctl.
> 
> I think it is for distributions to choose whether to enable this feature
> in ping and the kernel.

I am not (yet) buying this argument.

Saying 'you need to change sysctl foo for this to work' in a program manpage
is a lot different than 'you need to recompile the kernel'.
