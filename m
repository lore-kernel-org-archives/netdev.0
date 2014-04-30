From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: fix memory leak of publications
Date: Wed, 30 Apr 2014 13:32:16 -0400 (EDT)
Message-ID: <20140430.133216.2291735078400027118.davem@davemloft.net>
References: <1398741138-30523-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, huzhijiang@gmail.com,
	netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759256AbaD3RcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:32:18 -0400
In-Reply-To: <1398741138-30523-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 29 Apr 2014 11:12:18 +0800

> Commit 1bb8dce57f4d15233688c68990852a10eb1cd79f ("tipc: fix memory
> leak during module removal") introduced a memory leak issue: when
> name table is stopped, it's forgotten that publication instances are
> freed properly. Additionally the useless "continue" statement in
> tipc_nametbl_stop() is removed as well.
> 
> Reported-by: Jason <huzhijiang@gmail.com>
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: Erik Hugne <erik.hugne@ericsson.com>

Applied.
