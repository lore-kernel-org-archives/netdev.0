From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] xen-netback: implement dynamic multicast
 control
Date: Sun, 07 Feb 2016 14:02:50 -0500 (EST)
Message-ID: <20160207.140250.262912581711576971.davem@davemloft.net>
References: <1454414105-13327-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbcBGTCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 14:02:54 -0500
In-Reply-To: <1454414105-13327-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Tue, 2 Feb 2016 11:55:05 +0000

> My recent patch to the Xen Project documents a protocol for 'dynamic
> multicast control' in netif.h. This extends the previous multicast control
> protocol to not require a shared ring reconnection to turn the feature off.
> Instead the backend watches the "request-multicast-control" key in xenstore
> and turns the feature off if the key value is written to zero.
> 
> This patch adds support for dynamic multicast control in xen-netback.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Applied, thanks.
