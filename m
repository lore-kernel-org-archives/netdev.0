From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: add vlan filtering offload
Date: Wed, 29 Jul 2015 23:25:11 -0700 (PDT)
Message-ID: <20150729.232511.1863007804754354114.davem@davemloft.net>
References: <1438174366-21973-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbbG3GZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 02:25:12 -0400
In-Reply-To: <1438174366-21973-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Wed, 29 Jul 2015 15:52:46 +0300

> Current driver always uses vlan-promisc mode, i.e., it receives both
> tagged and untagged traffic and lets the network stack drop packets
> tagged with unrequested vlan tags.
> 
> This patch implements vlan-filtering offload in the driver -
> Unless explicitly configured to promisc mode, only untagged packets or
> packets tagged with requested vlans would reach the Rx flow.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
