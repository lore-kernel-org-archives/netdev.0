From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netpoll: fix a missing dev refcounting
Date: Wed, 16 Jan 2013 23:33:16 -0500 (EST)
Message-ID: <20130116.233316.1659669817588484278.davem@davemloft.net>
References: <1358396468-14938-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jiri@resnulli.us
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758287Ab3AQEdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 23:33:21 -0500
In-Reply-To: <1358396468-14938-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 17 Jan 2013 12:21:08 +0800

> __dev_get_by_name() doesn't refcount the network device,
> so we have to do this by ourselves. Noticed by Eric.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
