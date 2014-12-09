From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification
 until after ndo_uninit()
Date: Mon, 08 Dec 2014 20:44:32 -0500 (EST)
Message-ID: <20141208.204432.21257518653585631.davem@davemloft.net>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>
	<20141202100746.GA13717@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, edumazet@google.com,
	roopa@cumulusnetworks.com, makita.toshiaki@lab.ntt.co.jp
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756467AbaLIBoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 20:44:34 -0500
In-Reply-To: <20141202100746.GA13717@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 2 Dec 2014 10:07:46 +0000

> I think it would be cleaner to introduce a new function, for example
> rtmsg_ifinfo_build_skb() which is called from rtmsg_ifinfo(). The
> single caller that requires delayed sending can use the build skb
> function directly and then send it off.

+1
