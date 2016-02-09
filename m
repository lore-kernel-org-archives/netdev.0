From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: translate network order to host order when
 users get a hmacid
Date: Tue, 09 Feb 2016 04:54:09 -0500 (EST)
Message-ID: <20160209.045409.1138087933631573325.davem@davemloft.net>
References: <f763fd2125356a2484bef0b6d083fdd38b13e8db.1454513610.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbcBIJyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 04:54:32 -0500
In-Reply-To: <f763fd2125356a2484bef0b6d083fdd38b13e8db.1454513610.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed,  3 Feb 2016 23:33:30 +0800

> Commit ed5a377d87dc ("sctp: translate host order to network order when
> setting a hmacid") corrected the hmacid byte-order when setting a hmacid.
> but the same issue also exists on getting a hmacid.
> 
> We fix it by changing hmacids to host order when users get them with
> getsockopt.
> 
> Fixes: Commit ed5a377d87dc ("sctp: translate host order to network order when setting a hmacid")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.

Thanks.
