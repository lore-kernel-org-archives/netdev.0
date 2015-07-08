From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "dev: set iflink to 0 for virtual
 interfaces"
Date: Wed, 08 Jul 2015 15:52:59 -0700 (PDT)
Message-ID: <20150708.155259.2222933180114223309.davem@davemloft.net>
References: <5589959A.8060600@hartkopp.net>
	<1436196310-4090-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, ulrich.gemkow@ikr.uni-stuttgart.de,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38108 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751041AbbGHWxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 18:53:01 -0400
In-Reply-To: <1436196310-4090-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon,  6 Jul 2015 17:25:10 +0200

> This reverts commit e1622baf54df8cc958bf29d71de5ad545ea7d93c.
> 
> The side effect of this commit is to add a '@NONE' after each virtual
> interface name with a 'ip link'. It may break existing scripts.
> 
> Reported-by: Olivier Hartkopp <socketcan@hartkopp.net>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied and queued up for -stable, thanks.
