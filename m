From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/3] intermediate representation for jit and
 cls_u32 conversion
Date: Fri, 26 Feb 2016 12:40:44 -0500 (EST)
Message-ID: <20160226.124044.1659531163671654774.davem@davemloft.net>
References: <20160226114036.GA2523@salvia>
	<56D07261.1060302@gmail.com>
	<20160226161948.GA4667@salvia>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, netdev@vger.kernel.org, jiri@resnulli.us,
	horms@verge.net.au
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030302AbcBZRkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:40:47 -0500
In-Reply-To: <20160226161948.GA4667@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 26 Feb 2016 17:19:48 +0100

> I see no reason to have as many hooks as frontends to start with. If
> you find limitations with the IR that are unfixable for any of the
> existing frontends in the future, then we can add direct hook as final
> solution.

I see no problem with adding many hooks, one for each class of things
we'd like to offload.  Stuff neading IR vs. stuff that does not.

And IR is "unfixable" for the latter case in that it will always be by
definition pure overhead if the cards can do this stuff directly, and
they can.

I do not encourage anything, in any way whatsoever, to try and genericize
all of this stuff into a generic framework.  That is wasted work in my
opinion.

You find an IR useful for nftables offloads, great!  But I do not see it
being useful nor desirable for u32, flower, et al.

Thanks.
