From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bridge: add flags to distinguish permanent mdb
 entires
Date: Sat, 15 Dec 2012 17:16:56 -0800 (PST)
Message-ID: <20121215.171656.1197452765852503859.davem@davemloft.net>
References: <1355558992-32285-1-git-send-email-amwang@redhat.com>
	<1355558992-32285-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.hengli.com.au, shemminger@vyatta.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926Ab2LPBQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2012 20:16:56 -0500
In-Reply-To: <1355558992-32285-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 15 Dec 2012 16:09:51 +0800

> This patch adds a flag to each mdb entry, so that we can distinguish
> permanent entries with temporary entries.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, but you _really_ need to lock down the interface and
stop making changes to the user visible side of this _now_.

Thanks.
