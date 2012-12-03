From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tuntap: attach queue 0 before registering
 netdevice
Date: Mon, 03 Dec 2012 13:49:18 -0500 (EST)
Message-ID: <20121203.134918.1505727312476469482.davem@davemloft.net>
References: <1354504785-13036-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jslaby@suse.cz
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab2LCStU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:49:20 -0500
In-Reply-To: <1354504785-13036-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon,  3 Dec 2012 11:19:45 +0800

> We attach queue 0 after registering netdevice currently. This leads to call
> netif_set_real_num_{tx|rx}_queues() after registering the netdevice. Since we
> allow tun/tap has a maximum of 1024 queues, this may lead a huge number of
> uevents to be injected to userspace since we create 2048 kobjects and then
> remove 2046. Solve this problem by attaching queue 0 and set the real number of
> queues before registering netdevice.
> 
> Reported-by: Jiri Slaby <jslaby@suse.cz>
> Tested-by: Jiri Slaby <jslaby@suse.cz>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
