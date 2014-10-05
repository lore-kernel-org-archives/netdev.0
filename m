From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_gre: fix flowi6_proto value in xmit path
Date: Sat, 04 Oct 2014 20:09:07 -0400 (EDT)
Message-ID: <20141004.200907.1393950992730416823.davem@davemloft.net>
References: <1412267209-893-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43998 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEAJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:09:08 -0400
In-Reply-To: <1412267209-893-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu,  2 Oct 2014 18:26:49 +0200

> In xmit path, we build a flowi6 which will be used for the output route lookup.
> We are sending a GRE packet, neither IPv4 nor IPv6 encapsulated packet, thus the
> protocol should be IPPROTO_GRE.
> 
> Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
> Reported-by: Matthieu Ternisien d'Ouville <matthieu.tdo@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
