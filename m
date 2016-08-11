From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: fix use after free for skb_array during
 release
Date: Thu, 11 Aug 2016 09:56:20 -0700 (PDT)
Message-ID: <20160811.095620.2209757084053700354.davem@davemloft.net>
References: <1470910556-11872-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	borntraeger@de.ibm.com, cornelia.huck@de.ibm.com, mst@redhat.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932489AbcHKQ4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 12:56:22 -0400
In-Reply-To: <1470910556-11872-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 11 Aug 2016 18:15:56 +0800

> We've clean skb_array in macvtap_put_queue() but still try to pop from
> it during macvtap_sock_destruct(). Fix this use after free by moving
> the skb array cleanup to macvtap_sock_destruct() instead.
> 
> Fixes: 362899b8725b ("macvtap: switch to use skb array")
> Reported-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> Tested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks for fixing this so quickly Jason.
