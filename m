From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] netlink: eliminate nl_sk_hash_lock
Date: Mon, 12 Jan 2015 16:27:03 -0500 (EST)
Message-ID: <20150112.162703.804704527828090208.davem@davemloft.net>
References: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
	<1420791818-22150-3-git-send-email-ying.xue@windriver.com>
	<20150109105516.GA1600@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54098 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbbALV1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:27:06 -0500
In-Reply-To: <20150109105516.GA1600@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 9 Jan 2015 10:55:16 +0000

> Since this code can now run in parallel, there is a race between
> checking portid and then setting it. CPU#1 could overwrite portid after
> CPU#0 has already checked portid, this would then insert the socket on
> CPU#0 with the portid created on CPU#1. So this would need some kind
> of atomic operation.

Thomas, please review Ying's new version of this patch.

Thanks.
