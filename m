From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pppoe: fix memory corruption in padt work structure
Date: Fri, 04 Dec 2015 16:49:47 -0500 (EST)
Message-ID: <20151204.164947.1753713332502681473.davem@davemloft.net>
References: <8d1438dac05eb64026c51086770a8875a26b103b.1449156478.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nitr0@seti.kr.ua
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756644AbbLDVtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 16:49:49 -0500
In-Reply-To: <8d1438dac05eb64026c51086770a8875a26b103b.1449156478.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 3 Dec 2015 16:49:32 +0100

> pppoe_connect() mustn't touch the padt_work field of pppoe sockets
> because that work could be already pending.
 ...
> Reported-by: Andrew <nitr0@seti.kr.ua>
> Fixes: 287f3a943fef ("pppoe: Use workqueue to die properly when a PADT is received")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks!
