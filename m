From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix_diag: Fix incoming connections nla length
Date: Mon, 26 Dec 2011 14:08:56 -0500 (EST)
Message-ID: <20111226.140856.691170806683181183.davem@davemloft.net>
References: <4EF7804D.4050300@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab1LZTJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 14:09:03 -0500
In-Reply-To: <4EF7804D.4050300@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Sun, 25 Dec 2011 23:58:05 +0400

> The NLA_PUT macro should accept the actual attribute length, not
> the amount of elements in array :(
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied, thanks.
