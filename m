From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: core: Fix race condition in
 __mlxsw_emad_transmit
Date: Thu, 15 Oct 2015 06:03:33 -0700 (PDT)
Message-ID: <20151015.060333.2244517960846953271.davem@davemloft.net>
References: <1444890115-1726-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbbJOMr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 08:47:27 -0400
In-Reply-To: <1444890115-1726-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 15 Oct 2015 08:21:55 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Under certain conditions EMAD responses can be returned from the device
> even before setting trans_active. This will cause the EMAD Rx listener
> to drop the EMAD response - as there are no active transactions - and
> timeouts will be generated.
> 
> Fix this by setting trans_active before transmitting the EMAD skb.
> 
> Fixes: 4ec14b7634b2 ("mlxsw: Add interface to access registers and process events")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
