From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: Don't propagate IFF_ALLMULTI changes on down
 interfaces.
Date: Fri, 09 May 2014 16:02:25 -0400 (EDT)
Message-ID: <20140509.160225.1543592257804345860.davem@davemloft.net>
References: <1399540537-19262-1-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756553AbaEIUC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 16:02:27 -0400
In-Reply-To: <1399540537-19262-1-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Christensen <pch@ordbogen.com>
Date: Thu,  8 May 2014 11:15:37 +0200

> Clearing the IFF_ALLMULTI flag on a down interface could cause an allmulti
> overflow on the underlying interface.
> 
> Attempting the set IFF_ALLMULTI on the underlying interface would cause an
> error and the log message:
> 
> "allmulti touches root, set allmulti failed."
> 
> Signed-off-by: Peter Christensen <pch@ordbogen.com>

Hmmm, but won't we lose this event once the interface is brought
back up?
