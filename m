From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qualcomm: Fix dependancy
Date: Tue, 11 Nov 2014 16:19:02 -0500 (EST)
Message-ID: <20141111.161902.716667007371046451.davem@davemloft.net>
References: <1415740110-19518-1-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefan.wahren@i2se.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbaKKVVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 16:21:14 -0500
In-Reply-To: <1415740110-19518-1-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Wahren <stefan.wahren@i2se.com>
Date: Tue, 11 Nov 2014 21:08:30 +0000

> Unfortunately the patch for adding QCA7000 driver contains an old
> version of Kconfig, which requires OF_GPIO. This is not necessary
> anymore and need to be replaced with OF.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>

Actually, I would remove the dependencies entirely from the
VENDOR Kconfig entry, that makes no sense.

It's the individual drivers that need this or that, so that's where
the dependency checks belong.
