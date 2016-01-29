From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] network driver fixes
Date: Thu, 28 Jan 2016 16:14:13 -0800 (PST)
Message-ID: <20160128.161413.1463071323452305953.davem@davemloft.net>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751189AbcA2AOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:14:14 -0500
In-Reply-To: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 27 Jan 2016 15:04:50 +0100

> These are all fixes for relatively harmless bugs that showed up
> in my randconfig testing, so they should not be needed for v4.5
> but get merged into net-next.
> 
> I've managed to address all 'uninitialized variable' warnings that
> I get in ARM randconfig kernels now, this series includes the
> last five I got in network drivers. They are often really annoying
> warnings but when we get new ones, they often are about actual
> bugs in corner cases, so I'm trying hard to eliminate the false
> positives here to get people to pay attention to added warnings.
> I've recently tried building with an older gcc and found tons more
> that are all bogus, this series only addresses the ones that
> gcc-5.2 finds.

Arnd I'm expecting a respin of this series to address with the
feedback you've been given.

Thanks.
