From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] packet: minor: make if case unlikely
Date: Tue, 23 Oct 2012 13:12:53 -0400 (EDT)
Message-ID: <20121023.131253.779417489113821973.davem@davemloft.net>
References: <20121023115833.GB8664@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42297 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933128Ab2JWRMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:12:54 -0400
In-Reply-To: <20121023115833.GB8664@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Tue, 23 Oct 2012 13:58:34 +0200

> This patch fixes the character width of max. 80 chars and also marks the
> if-statement as unlikely since those flags are not supported for the receive
> path anyway.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Please, don't submit patches like this.

80 characters is a soft "guidelline" there is no strict requirement
for it.

I'm tossing this entire series.
