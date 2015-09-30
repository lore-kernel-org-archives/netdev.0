From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/mlx4: Handle return codes in
 mlx4_qp_attach_common
Date: Tue, 29 Sep 2015 21:15:44 -0700 (PDT)
Message-ID: <20150929.211544.2010703361386126834.davem@davemloft.net>
References: <20150928.222642.1395622340146984028.davem@davemloft.net>
	<1443539017-4851-1-git-send-email-rmanes@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, eyalpe@mellanox.com,
	ogerlitz@mellanox.com
To: rmanes@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbbI3EPp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 00:15:45 -0400
In-Reply-To: <1443539017-4851-1-git-send-email-rmanes@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robb Manes <rmanes@redhat.com>
Date: Tue, 29 Sep 2015 11:03:37 -0400

> Both new_steering_entry() and existing_steering_entry() return values
> based on their success or failure, but currently they fall through
> silently.  This can make troubleshooting difficult, as we were unable
> to tell which one of these two functions returned errors or
> specifically what code was returned.  This patch remedies that
> situation by passing the return codes to err, which is returned by
> mlx4_qp_attach_common() itself.
> 
> This also addresses a leak in the call to mlx4_bitmap_free() as well.
> 
> Signed-off-by: Robb Manes <rmanes@redhat.com>

Applied, thank you.
