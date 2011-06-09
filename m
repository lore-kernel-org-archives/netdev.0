From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: do not put self in waitq if doing a nonblock read
Date: Thu, 09 Jun 2011 00:27:21 -0700 (PDT)
Message-ID: <20110609.002721.963829441380663942.davem@davemloft.net>
References: <20110608234606.8681.19932.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, kvm@vger.kernel.org,
	mst@redhat.com
To: akong@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab1FIH1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:27:25 -0400
In-Reply-To: <20110608234606.8681.19932.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amos Kong <akong@redhat.com>
Date: Thu, 09 Jun 2011 07:46:06 +0800

> Perf shows a relatively high rate (about 8%) race in
> spin_lock_irqsave() when doing netperf between external host and
> guest. It's mainly becuase the lock contention between the
> tun_do_read() and tun_xmit_skb(), so this patch do not put self into
> waitqueue to reduce this kind of race. After this patch, it drops to
> 4%.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Amos Kong <akong@redhat.com>

Applied, thanks.
