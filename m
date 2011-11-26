From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-net: Acquire device lock when releasing device
Date: Sat, 26 Nov 2011 15:45:03 -0500 (EST)
Message-ID: <20111126.154503.1317670837061338352.davem@davemloft.net>
References: <1321607982-16283-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: levinsasha928@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753603Ab1KZUpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2011 15:45:11 -0500
In-Reply-To: <1321607982-16283-1-git-send-email-levinsasha928@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <levinsasha928@gmail.com>
Date: Fri, 18 Nov 2011 11:19:42 +0200

> Device lock should be held when releasing a device, and specifically
> when calling vhost_dev_cleanup(). Otherwise, RCU complains about it:
 ...
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: kvm@vger.kernel.org
> Cc: virtualization@lists.linux-foundation.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Michael et al., are you guys going to gather this fix or should I
apply it directly to thet net tree?

Thanks.
