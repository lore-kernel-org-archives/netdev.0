From: David Miller <davem@davemloft.net>
Subject: Re: pull request [net-next]: batman-adv 20160210
Date: Thu, 11 Feb 2016 03:50:33 -0500 (EST)
Message-ID: <20160211.035033.2047139693612194678.davem@davemloft.net>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: a@unstable.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751921AbcBKIuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 03:50:37 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <a@unstable.cc>
Date: Wed, 10 Feb 2016 23:57:06 +0800

> this is another pull request intended for net-next.
> 
> Here you have a batch of patches by Sven Eckelmann that
> drops our private reference counting implementation and
> substitutes it with the kref objects/functions.
> 
> Then you have a patch, by Simon Wunderlich, that
> makes the broadcast protection window code more generic so
> that it can be re-used in the future by other components
> with different requirements.
> 
> Lastly, Sven is also introducing two lockdep asserts in
> functions operating on our TVLV container list, to make
> sure that the proper lock is always acquired by the users.

Pulled, thanks Antonio.
