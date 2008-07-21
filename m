From: James Morris <jmorris@namei.org>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 21:45:58 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0807212143540.17349@us.intercode.com.au>
References: <20080720.104411.81744468.davem@davemloft.net>
 <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org>
 <20080720.180304.51601407.davem@davemloft.net> <4883E465.4050405@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:49634 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751590AbYGULqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 07:46:45 -0400
In-Reply-To: <4883E465.4050405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jul 2008, Patrick McHardy wrote:

> > James/Patrick please fix this.
> >   
> 
> This is only the NETFILTER_ADVANCED=n default (for SECURITY=y).
> The netfilter defaults for NETFILTER_ADVANCED=n should be m/y for
> things that are needed by mainstream distributions for normal
> usage.
> 
> I'm not sure how this is going to be used, James?

I think the idea now is that everything new is N by default, but the 
intention is to have this enabled in Fedora/RHEL.

Patrick, would you please fix this up?  The only dev box I have access to 
at the moment doesn't boot with recent git (I think it's the macbook2 
issue).


- James
-- 
James Morris
<jmorris@namei.org>
