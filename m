From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Expose the initial RTO via a new sysctl.
Date: Wed, 18 May 2011 15:52:00 -0400 (EDT)
Message-ID: <20110518.155200.801089483916944725.davem@davemloft.net>
References: <1305715384-81716-1-git-send-email-tsunanet@gmail.com>
	<20110518.152653.1486764697527722925.davem@davemloft.net>
	<BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tsunanet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab1ERTzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 15:55:49 -0400
In-Reply-To: <BANLkTik-6wh8=jb6oMEpJvYC8+KTGGsMsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: tsuna <tsunanet@gmail.com>
Date: Wed, 18 May 2011 12:40:21 -0700

> I was hoping this knob would be accepted because this is such an
> important issue that it even warrants an IETF draft to attempt to
> change the standard.  I'm not sure how long it will take for this
> draft to be accepted and then implemented, so I thought adding this
> simple knob today would really help in the future.

I've already changed the initial TCP congestion window in Linux to 10
without some stupid draft being fully accepted.

I'll just as easily accept right now a patch right now which lowers
the initial RTO to 1 second and adds the 3 second RTO fallback.
