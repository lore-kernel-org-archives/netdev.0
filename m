From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: replace last open coded skb_orphan_frags
 with function call
Date: Mon, 08 Jun 2015 12:15:54 -0700 (PDT)
Message-ID: <20150608.121554.1931679506253459434.davem@davemloft.net>
References: <1433778788-16971-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbbFHTPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 15:15:55 -0400
In-Reply-To: <1433778788-16971-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon,  8 Jun 2015 11:53:08 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Commit 70008aa50e92 ("skbuff: convert to skb_orphan_frags") replaced
> open coded tests of SKBTX_DEV_ZEROCOPY and skb_copy_ubufs with calls
> to helper function skb_orphan_frags. Apply that to the last remaining
> open coded site.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
