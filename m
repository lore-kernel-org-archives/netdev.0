From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] macvtap: fix network header pointer for VLAN
 tagged pkts
Date: Mon, 27 Jul 2015 15:58:32 -0700 (PDT)
Message-ID: <20150727.155832.101768068706820064.davem@davemloft.net>
References: <1437662263-2733-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevich@gmail.com,
	toshiaki.makita1@gmail.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754664AbbG0W6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 18:58:33 -0400
In-Reply-To: <1437662263-2733-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 23 Jul 2015 16:37:43 +0200

> Network header is set with offset ETH_HLEN but it is not true for VLAN
> (multiple-)tagged and results in checksum issues in lower devices.
> 
> v2: leave skb->protocol untouched (thx Vlad), comment added
> v3: moved after skb_probe_transport_header() call (thx Toshiaki)
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thanks.
