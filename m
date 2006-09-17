From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: tcp congestion policy selection link order fragile
Date: Sun, 17 Sep 2006 22:11:51 +0900
Message-ID: <20060917221151.7d343f3f@localhost.localdomain>
References: <20060916221948.GA12421@outpost.ds9a.nl>
	<20060917083214.45b5f61f@localhost.localdomain>
	<20060917101101.GA30461@outpost.ds9a.nl>
	<20060917205351.4f691c4e@localhost.localdomain>
	<20060917122153.GA2932@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55507 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932426AbWIQNMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2006 09:12:24 -0400
To: bert hubert <bert.hubert@netherlabs.nl>
In-Reply-To: <20060917122153.GA2932@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 17 Sep 2006 14:21:53 +0200
bert hubert <bert.hubert@netherlabs.nl> wrote:

> On Sun, Sep 17, 2006 at 08:53:51PM +0900, Stephen Hemminger wrote:
> 
> > Depending on load order is not good, and not a safe way to configure.
> 
> I agree fully.
> 
> > If you want a particular value set it with sysctl!
> 
> Operators, distributors and even people who've been doing kernel stuff for
> more than a decade expect to be able to compile in (experimental) policies,
> and not have a *random* one of them enabled by default!

Any body who builds in random stuff without thinking is being foolish.
But, if you can think of a better configuration method that isn't too
grotty, then go for it.
