From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: hisax: netjet requires VIRT_TO_BUS
Date: Sun, 17 Mar 2013 12:01:46 -0400 (EDT)
Message-ID: <20130317.120146.1958709702875370639.davem@davemloft.net>
References: <1363298204-8014-1-git-send-email-arnd@arndb.de>
	<1363298204-8014-4-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756473Ab3CQQBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Mar 2013 12:01:47 -0400
In-Reply-To: <1363298204-8014-4-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 14 Mar 2013 22:56:41 +0100

> Disabling CONFIG_VIRT_TO_BUS on ARM showed that the hisax netjet
> driver depends on this deprecated functionality but is not
> marked so in Kconfig.
> 
> Rather than adding ARM to the already long list of architectures
> that this driver is broken on, this patch adds 'depends on
> VIRT_TO_BUS' and removes the dependency on !SPARC, which is
> also implied by that.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
