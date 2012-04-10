From: David Miller <davem@davemloft.net>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 09:52:45 -0400 (EDT)
Message-ID: <20120410.095245.1556231435417125908.davem@davemloft.net>
References: <4F841BB9.2030209@monstr.eu>
	<20120410.094301.415649892550737376.davem@davemloft.net>
	<CAHTX3dLRR09_QaA2BzmbCVAUVVGvr_P3s2d1KEgPLMYGGVzrpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	john.williams@petalogix.com
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097Ab2DJNwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 09:52:49 -0400
In-Reply-To: <CAHTX3dLRR09_QaA2BzmbCVAUVVGvr_P3s2d1KEgPLMYGGVzrpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <monstr@monstr.eu>
Date: Tue, 10 Apr 2012 15:49:17 +0200

> I reported problem with performance regression on the same drvier
> between one kernel version and the newer version. Even with pointer
> to specific patch which I have identified as source of the problem.
> It has nothing to do with performance of driver itself because
> identified patch directly points to generic network code not to
> mainline driver and performance problem in it.

The size and attributes of the SKBs allocated is a clear important
variable in this bug, and you've just described how the SKBs allocated
are of completely different sizes in the driver you're using compared
to the one in the tree.

You were very fortunate that Eric was able to track down the cause
even with this unknown variable, but in other cases this can lead to
wild goose chases which waste developer time.

So, again, please do not do this in the future, reproduce your
problems with upstream sources only.
