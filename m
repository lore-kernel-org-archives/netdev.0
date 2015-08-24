From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: Avoid sleeping in bcmgenet_timeout
Date: Sun, 23 Aug 2015 22:59:58 -0700 (PDT)
Message-ID: <20150823.225958.949245344089566556.davem@davemloft.net>
References: <1440119062-19677-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pgynther@google.com, jaedon.shin@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbbHXGAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 02:00:02 -0400
In-Reply-To: <1440119062-19677-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 20 Aug 2015 18:04:22 -0700

> bcmgenet_timeout() executes in atomic context, yet we will invoke
> napi_disable() which does sleep. Looking back at the changes, disabling
> TX napi and re-enabling it is completely useless, since we reclaim all
> TX buffers and re-enable interrupts, and wake up the TX queues.
> 
> Fixes: 13ea657806cf ("net: bcmgenet: improve TX timeout")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
