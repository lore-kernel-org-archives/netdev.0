From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: tcp congestion policy selection link order fragile
Date: Mon, 18 Sep 2006 16:41:20 -0700
Message-ID: <20060918164120.7d658e8b@localhost.localdomain>
References: <20060916221948.GA12421@outpost.ds9a.nl>
	<20060917083214.45b5f61f@localhost.localdomain>
	<20060917101101.GA30461@outpost.ds9a.nl>
	<20060917205351.4f691c4e@localhost.localdomain>
	<20060917122153.GA2932@outpost.ds9a.nl>
	<20060917221151.7d343f3f@localhost.localdomain>
	<20060917145150.GA7223@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21203 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030262AbWIRXlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 19:41:45 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060917145150.GA7223@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 17 Sep 2006 16:51:50 +0200
bert hubert <bert.hubert@netherlabs.nl> wrote:

> The original message Stephen reacts to below apparently never made it to the
> list, it can be found here: http://ds9a.nl/tmp/module-policy.txt
> 
> > Any body who builds in random stuff without thinking is being foolish.
> > But, if you can think of a better configuration method that isn't too
> > grotty, then go for it.
> 
> The method I'm proposing is simple enough:
> 
> 1) reno is always built-in
> 2) it is the default tcp congestion policy

No, Reno is unstable in high BDP

> 3) loading/compiling-in additional tcp congestion policies only make them
>    available
> 4) userspace is free to select a non-default tcp congestion policy at will
> 
> The implementation might be as simple as making the *first* registered
> congestion policy the default (instead of the last one) which would be reno,
> as it is in tcp_cong.o, which is probably always loaded first (as the other
> .o's need symbols that are in tcp_cong.o).
> 
> Despite what you allege about my foolishness, I maintain that a kernel that
> enables a *random policy* from the ones you compiled in, is not a sane
> kernel.
> 
> The default kernel should be as sane as possible, allowing the userspace
> people (ie, me) to mess things up to their heart's desire.
> 
> 	Bert
> 
