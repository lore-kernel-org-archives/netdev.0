From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid tcp loop connection on lo device
Date: Tue, 25 Sep 2012 13:04:36 -0400 (EDT)
Message-ID: <20120925.130436.2297001740930119160.davem@davemloft.net>
References: <50616772.8040704@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shanwei88@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756654Ab2IYREk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 13:04:40 -0400
In-Reply-To: <50616772.8040704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei88@gmail.com>
Date: Tue, 25 Sep 2012 16:12:34 +0800

> Tcp supports simultaneous Connection, but we meat odd phenomenon
> that tcp client can receive what send by itself. tcp client and tcp
> server communicate through loop device. tcp server selects port
> 40000 to listen which is in local port range. But after tcp server
> program is killed, tcp client still can connect successfully.

This is expected behavior and we're not special casing this after
it being this way for 20+ years.
