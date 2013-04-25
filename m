From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix locking in enslave failure path
Date: Thu, 25 Apr 2013 04:04:59 -0400 (EDT)
Message-ID: <20130425.040459.1780796133595305415.davem@davemloft.net>
References: <1366654342-2715-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab3DYIFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:05:01 -0400
In-Reply-To: <1366654342-2715-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Mon, 22 Apr 2013 20:12:22 +0200

> In commit 3c5913b53fefc9d9e15a2d0f93042766658d9f3f ("bonding:
> primary_slave & curr_active_slave are not cleaned on enslave failure")
> I didn't account for the use of curr_active_slave without curr_slave_lock
> and since there are such users, we should hold bond->lock for writing while
> setting it to NULL (in the NULL case we don't need the curr_slave_lock).
> Keeping the bond lock as to avoid the extra release/acquire cycle.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>

Applied, thanks.
