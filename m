From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neighbour: update neigh timestamps iff update is
 effective
Date: Mon, 15 May 2017 13:10:23 -0400 (EDT)
Message-ID: <20170515.131023.1878814687849300375.davem@davemloft.net>
References: <20170510000605.6799-1-ihrachys@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, hchunhui@mail.ustc.edu.cn, netdev@vger.kernel.org
To: ihrachys@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdEORK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 13:10:27 -0400
In-Reply-To: <20170510000605.6799-1-ihrachys@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ihar Hrachyshka <ihrachys@redhat.com>
Date: Tue,  9 May 2017 17:06:05 -0700

> Sometimes neigh_update calls won't touch neither lladdr nor state, for
> example if an update arrives in locktime interval. Then we effectively
> ignore the update request, bailing out of touching the neigh entry,
> except that we still bump its timestamps.

So, in order to understand this, one has to know that the ->updated
value is tested by the protocol specific neigh code, which in turn
will thus influence whether NEIGH_UPDATE_F_OVERRIDE gets set in the
call to neigh_update() or not.

Please update your commit message to explain that this is how the
locktime mechanism influences neigh_update()'s behavior.

Thank you.
