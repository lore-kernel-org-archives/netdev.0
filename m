From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] virtio_net: hook up the set-tso ethtool op
Date: Sun, 16 Nov 2008 22:40:46 -0800 (PST)
Message-ID: <20081116.224046.60665642.davem@davemloft.net>
References: <200811171344.57410.rusty@rustcorp.com.au>
	<200811171346.09039.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markmc@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752814AbYKQGkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 01:40:46 -0500
In-Reply-To: <200811171346.09039.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 17 Nov 2008 13:46:08 +1030

> Seems like an oversight that we have set-tx-csum and set-sg hooked
> up, but not set-tso.
> 
> Also leads to the strange situation that if you e.g. disable tx-csum,
> then tso doesn't get disabled.
> 
> Signed-off-by: Mark McLoughlin <markmc@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Applied.
