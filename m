From: David Miller <davem@davemloft.net>
Subject: Re: net: gcc-6.0 warning fixes
Date: Mon, 14 Mar 2016 13:10:48 -0400 (EDT)
Message-ID: <20160314.131048.1220349879118085878.davem@davemloft.net>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbcCNRKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:10:51 -0400
In-Reply-To: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 15:18:33 +0100

> I've just installed gcc-6.0 to see what kinds of new warnings
> we get. It turns out that it's actually really useful once I
> disabled -Wunused-const-variable, and all of the warnings it
> found in network drivers seem valid.
> 
> Sorry for the bad timing in the merge window, but I figured
> it would be better to send the fixes as I found the bugs
> rather than waiting for the next cycle. The first three
> look appropriate for stable backports.
> 
> The other two only fix a gcc warning about incorrect whitespace,
> probably not worth backporting those.

Series applied, and patches 1, 2, and 3 queued up for -stable.

Thanks.
