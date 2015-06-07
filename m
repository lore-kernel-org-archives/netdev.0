From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: improve TX timeout
Date: Sun, 07 Jun 2015 15:19:24 -0700 (PDT)
Message-ID: <20150607.151924.1043509285781683514.davem@davemloft.net>
References: <1433459750-14861-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jaedon.shin@gmail.com, pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652AbbFGWT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jun 2015 18:19:27 -0400
In-Reply-To: <1433459750-14861-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  4 Jun 2015 16:15:50 -0700

> Dump useful ring statistics along with interrupt status, software
> maintained pointers and hardware registers to help troubleshoot TX queue
> stalls.
> 
> When a timeout occurs, disable TX NAPI for the rings, dump their states
> while interrupts are disabled, re-enable interrupts, NAPI and queue flow
> control to help with the recovery.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
