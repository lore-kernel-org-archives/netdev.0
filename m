From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] soreuseport: fix NULL ptr dereference SO_REUSEPORT
 after bind
Date: Tue, 19 Jan 2016 14:44:52 -0500 (EST)
Message-ID: <20160119.144452.555969872261254175.davem@davemloft.net>
References: <1453231628-18603-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marc.c.dionne@gmail.com
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54404 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745AbcASToz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:44:55 -0500
In-Reply-To: <1453231628-18603-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 19 Jan 2016 14:27:08 -0500

> From: Craig Gallek <kraig@google.com>
> 
> Marc Dionne discovered a NULL pointer dereference when setting
> SO_REUSEPORT on a socket after it is bound.
> This patch removes the assumption that at least one socket in the
> reuseport group is bound with the SO_REUSEPORT option before other
> bind calls occur.
> 
> Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
> Reported-by: Marc Dionne <marc.c.dionne@gmail.com>
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thanks everyone.
