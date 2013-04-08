From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ieee802154_mlme_ops oops removal and
 cleanup
Date: Mon, 08 Apr 2013 12:00:48 -0400 (EDT)
Message-ID: <20130408.120048.1368784240584556424.davem@davemloft.net>
References: <cover.1365092820.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: werner@almesberger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936632Ab3DHQAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 12:00:50 -0400
In-Reply-To: <cover.1365092820.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Werner Almesberger <werner@almesberger.net>
Date: Thu, 4 Apr 2013 13:31:46 -0300

> This fixes a kernel oops we get when some linux-zigbee user
> space tools try to invoke unimplemented operations.
> 
> The second of the two patches checks whether the respective
> functions are present and returne EOPNOTSUPP if they aren't.
> It also updates the documentation.
> 
> The first one removes the unused get_bsn function, which was
> a small obstacle for the other patch.

Both applied, thanks.
