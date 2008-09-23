From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 23 Sep 2008 04:23:29 +0200
Message-ID: <20080923022329.GD25711@one.firstfloor.org>
References: <20080922232428.GA25711@one.firstfloor.org> <20080922.162158.223213897.davem@davemloft.net> <20080923001409.GB25711@one.firstfloor.org> <20080922.184012.212424947.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, csnook@redhat.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41039 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131AbYIWCSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:18:38 -0400
Content-Disposition: inline
In-Reply-To: <20080922.184012.212424947.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There are many cases where perfectly acceptible heuristics

For very low values of "perfect" :)

> don't perform optimally, this doesn't mean we disable them
> by default.

Well they're just broken on a larger and larger fraction
of the internet.  Router technology more and more often
knows something about ports these days and handles flows
differently. Assuming they do not is more and more 
wrong. It's one of these things which looks cool on first
look but when you dig deeper is just a bad idea.

How should we call a heuristics that is often
wrong. A "wrongistic"?  :)

> > NAT.
> 
> I am more than aware of this, however this doesn't mean it is
> sane 

I agree with you that they're not sane, but they should still 
be supported. Technically at least they don't violate any standards
afaik.

Linux should work well even with such setups. In fact it has
no other choice because they're so common. "Be liberal
what you accept, be conservative what you send". This violates
the second principle.

> and this kind of setup makes many useful internet services
> inaccessible.

Sure, in fact that's usually why they were done in the first place,
but Linux shouldn't make it unnecessarily worse.

Anyways enough said. I guess we have to agree to disagree on
this. For completeness I'll still send the patch to set the sysctl
by default though just in case you reconsider.

-Andi

-- 
ak@linux.intel.com
