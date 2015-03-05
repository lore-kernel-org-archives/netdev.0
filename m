From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/7] switchdev: add IPv4 routing offload
Date: Thu, 05 Mar 2015 00:04:37 -0500 (EST)
Message-ID: <20150305.000437.973765566269717091.davem@davemloft.net>
References: <CAE4R7bDBJye388V+itU9XqFNjruf0GcbXWFydx60fghiZp+NQw@mail.gmail.com>
	<20150304.160604.2259380248170644628.davem@davemloft.net>
	<CAE4R7bDTV38bR2Oo2nfO6gFQQBhC4avmWdYeK_2sj1bqZWQiEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815AbbCEFEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 00:04:39 -0500
In-Reply-To: <CAE4R7bDTV38bR2Oo2nfO6gFQQBhC4avmWdYeK_2sj1bqZWQiEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>
Date: Wed, 4 Mar 2015 20:50:28 -0800

> In v3, net/ipv4/*.c doesn't know if the driver skipped installing a
> route to hw.  The driver returns 0 as if it was installed. So the
> driver has to mark the ones actually installed.
> 
> This is why in v2 had return code -EOPNOTSUPP for routes that are
> skipped by driver.  For example, rocker currently skips ECMP routes.
> It's not an err condition.

The driver should say what it did.

> But I see driver could skip and not skip the wrong combination of
> routes such that we get a prefix split, for example.  We can't trust
> driver.

If the driver said "I did this" then we have to trust it, I don't
understand why this is an issue.
