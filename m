From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: lb: use sizeof(*fprog) in __fprog_create
Date: Sat, 24 May 2014 17:07:55 -0400 (EDT)
Message-ID: <20140524.170755.975426586766985727.davem@davemloft.net>
References: <1400960866-14450-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaEXVH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 17:07:59 -0400
In-Reply-To: <1400960866-14450-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 24 May 2014 21:47:46 +0200

> sock_fprog and sock_fprog_kern are of equal size, however
> it's cleaner to just use sizeof(*fprog) instead to always
> have correct type.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks Daniel.
