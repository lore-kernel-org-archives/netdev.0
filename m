From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Mon, 10 Sep 2012 16:32:29 -0400 (EDT)
Message-ID: <20120910.163229.421777922179988802.davem@davemloft.net>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com>
	<1347281326-26890-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932152Ab2IJUcb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 16:32:31 -0400
In-Reply-To: <1347281326-26890-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Mon, 10 Sep 2012 20:48:45 +0800

> It doesn't save any code, nor it helps readability.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>

I'm not applying this.

Having two copies of the same exact logic means we will accumulate
bugs in the future if someone fixes the problem only in one
copy.
