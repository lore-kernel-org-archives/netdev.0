From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvtap: correctly free skb during socket
 destruction
Date: Mon, 18 Jul 2016 22:11:39 -0700 (PDT)
Message-ID: <20160718.221139.864060644759685855.davem@davemloft.net>
References: <1468897379-4373-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dan.carpenter@oracle.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004AbcGSFLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 01:11:42 -0400
In-Reply-To: <1468897379-4373-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Tue, 19 Jul 2016 11:02:59 +0800

> We should use kfree_skb() instead of kfree() to free an skb.
> 
> Fixes: 362899b8725b ("macvtap: switch to use skb array")
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
