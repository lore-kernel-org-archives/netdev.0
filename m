From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: minor: remove unused err assignment
Date: Fri, 26 Oct 2012 02:17:48 -0400 (EDT)
Message-ID: <20121026.021748.2045558753254846096.davem@davemloft.net>
References: <20121024132723.GA21528@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab2JZGRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 02:17:49 -0400
In-Reply-To: <20121024132723.GA21528@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Wed, 24 Oct 2012 15:27:24 +0200

> This tiny patch removes two unused err assignments. In those two cases the
> err variable is either overwritten with another value at a later point in
> time without having read the previous assigment, or it is assigned and the
> function returns without using/reading err after the assignment.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>

Applied, thanks.
