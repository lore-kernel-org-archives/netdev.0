From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tuntap: restore default qdisc
Date: Fri, 08 Apr 2016 15:53:24 -0400 (EDT)
Message-ID: <20160408.155324.1589940627843005867.davem@davemloft.net>
References: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, phil@nwl.cc
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090AbcDHTx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 15:53:27 -0400
In-Reply-To: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri,  8 Apr 2016 13:26:48 +0800

> After commit f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using
> alloc_netdev"), default qdisc was changed to noqueue because
> tuntap does not set tx_queue_len during .setup(). This patch restores
> default qdisc by setting tx_queue_len in tun_setup().
> 
> Fixes: f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
> Cc: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied and queued up for -stable, thanks Jason.
