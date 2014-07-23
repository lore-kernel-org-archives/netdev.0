From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: correctly pad short packets
Date: Tue, 22 Jul 2014 19:59:58 -0700 (PDT)
Message-ID: <20140722.195958.1240820537660940041.davem@davemloft.net>
References: <1406052112-19958-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54047 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502AbaGWC77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 22:59:59 -0400
In-Reply-To: <1406052112-19958-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 22 Jul 2014 11:01:52 -0700

> Packets shorter than ETH_ZLEN were not padded with zeroes, hence leaking
> potentially sensitive information. This bug has been present since the
> driver got accepted in commit 1c1008c793fa46703a2fee469f4235e1c7984333
> ("net: bcmgenet: add main driver file").
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.
