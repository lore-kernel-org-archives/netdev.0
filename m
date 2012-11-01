From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 RESEND 3/6] net: calxedaxgmac: use relaxed i/o
 accessors in rx and tx paths
Date: Thu, 01 Nov 2012 12:05:21 -0400 (EDT)
Message-ID: <20121101.120521.1275464127408297624.davem@davemloft.net>
References: <1351766464-27354-4-git-send-email-robherring2@gmail.com>
	<20121101.112141.2093388998181270335.davem@davemloft.net>
	<50929BCF.3070503@calxeda.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: rob.herring@calxeda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60671 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933964Ab2KAQFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 12:05:23 -0400
In-Reply-To: <50929BCF.3070503@calxeda.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>
Date: Thu, 01 Nov 2012 10:57:03 -0500

> Or would you be okay with using __raw_readl/__raw_writel?

Those should be provided by all HAS_IOMEM platforms, so yes.
