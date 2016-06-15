From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: fix csum generation for tap devices
Date: Wed, 15 Jun 2016 14:00:57 -0700 (PDT)
Message-ID: <20160615.140057.269655953482473722.davem@davemloft.net>
References: <b4a4ba554658d07e8213e1e57cddef2f9485cc1b.1465854647.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, rppt@linux.vnet.ibm.com,
	hannes@stressinduktion.org
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbcFOVA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:00:58 -0400
In-Reply-To: <b4a4ba554658d07e8213e1e57cddef2f9485cc1b.1465854647.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 14 Jun 2016 00:00:04 +0200

> The commit 34166093639b ("tuntap: use common code for virtio_net_hdr
> and skb GSO conversion") replaced the tun code for header manipulation
> with the generic helpers. While doing so, it implictly moved the
> skb_partial_csum_set() invocation after eth_type_trans(), which
> invalidate the current gso start/offset values.
> Fix it by moving the helper invocation before the mac pulling.
> 
> Fixes: 34166093639 ("tuntap: use common code for virtio_net_hdr and skb GSO conversion")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
