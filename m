From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio_net: fix csum generation for
 virtio-net devices
Date: Tue, 14 Jun 2016 03:04:06 -0400 (EDT)
Message-ID: <20160614.030406.185717833189171632.davem@davemloft.net>
References: <1465882178-5098-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, dsa@cumulusnetworks.com
To: rppt@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbcFNHEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 03:04:07 -0400
In-Reply-To: <1465882178-5098-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Tue, 14 Jun 2016 08:29:38 +0300

> The commit e858fae2b0b8 ("virtio_net: use common code for virtio_net_hdr
> and skb GSO conversion") replaced the tun code for header manipulation
> with the generic helpers. While doing so, it implictly moved the
> skb_partial_csum_set() invocation after eth_type_trans(), which
> invalidate the current gso start/offset values.
> Fix it by moving the helper invocation before the mac pulling.
> 
> Fixes: e858fae2b0b8 ("virtio_net: use common code for virtio_net_hdr and
> skb GSO conversion")
> 
> Reported-by: David Ahern <dsa@cumulusnetworks.com>
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

Applied.
