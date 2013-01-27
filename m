From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Remove leftover #endif after introducing
 SO_REUSEPORT
Date: Sun, 27 Jan 2013 01:01:58 -0500 (EST)
Message-ID: <20130127.010158.212932494760006724.davem@davemloft.net>
References: <20130125100058.GJ11342@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776Ab3A0GB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 01:01:59 -0500
In-Reply-To: <20130125100058.GJ11342@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 25 Jan 2013 10:00:58 +0000

> Commit 055dc21a1d (soreuseport: infrastructure) removed the #if 0
> around SO_REUSEPORT without removing the corresponding #endif
> thus causing the header guard to close early.
> 
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
