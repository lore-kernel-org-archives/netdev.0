From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH net] tuntap: restore default qdisc
Date: Fri, 8 Apr 2016 11:02:34 +0200
Message-ID: <20160408090234.GT8724@orbyte.nwl.cc>
References: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:47575 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755381AbcDHJCh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2016 05:02:37 -0400
Content-Disposition: inline
In-Reply-To: <1460093208-4364-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2016 at 01:26:48PM +0800, Jason Wang wrote:
> After commit f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using
> alloc_netdev"), default qdisc was changed to noqueue because
> tuntap does not set tx_queue_len during .setup(). This patch restores
> default qdisc by setting tx_queue_len in tun_setup().
> 
> Fixes: f84bb1eac027 ("net: fix IFF_NO_QUEUE for drivers using alloc_netdev")
> Cc: Phil Sutter <phil@nwl.cc>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Phil Sutter <phil@nwl.cc>
