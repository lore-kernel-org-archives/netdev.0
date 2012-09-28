From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to
 specifiy the time of TIME-WAIT
Date: Fri, 28 Sep 2012 02:43:36 -0400 (EDT)
Message-ID: <20120928.024336.598451765169362800.davem@davemloft.net>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
	<20120927142334.GA3194@neilslaptop.think-freely.org>
	<1348813987.7264.41.camel@cr0>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, kaber@trash.net, edumazet@google.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab2I1Gni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 02:43:38 -0400
In-Reply-To: <1348813987.7264.41.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 28 Sep 2012 14:33:07 +0800

> I don't think reducing TIME_WAIT is a good idea either, but there must
> be some reason behind as several UNIX provides a microsecond-scale
> tuning interface, or maybe in non-recycle mode, their RTO is much less
> than 2*MSL?

Yes, there is a reason.  It's there for retaining multi-million-dollar
customers.

There is no other reasons these other systems provide these
facilities, they are simply there in an attempt to retain a dwindling
customer base.

Any other belief is extremely naive.
