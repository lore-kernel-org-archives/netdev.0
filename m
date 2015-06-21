From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/3] net/xen-netfront: Correct printf format in
 xennet_get_responses
Date: Sun, 21 Jun 2015 09:41:34 -0700 (PDT)
Message-ID: <20150621.094134.1149270002243134887.davem@davemloft.net>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	<1434481848-26387-2-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	david.vrabel@citrix.com, konrad.wilk@oracle.com,
	boris.ostrovsky@oracle.com, netdev@vger.kernel.org
To: julien.grall@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbbFUQ3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:29:48 -0400
In-Reply-To: <1434481848-26387-2-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Grall <julien.grall@citrix.com>
Date: Tue, 16 Jun 2015 20:10:46 +0100

> rx->status is an int16_t, print it using %d rather than %u in order to
> have a meaningful value when the field is negative.
> 
> Also use %u rather than %x for rx->offset.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Reviewed-by: David Vrabel <david.vrabel@citrix.com>

Applied.
