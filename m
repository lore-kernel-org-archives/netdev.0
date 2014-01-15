From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] neigh: use NEIGH_VAR_INIT in ndo_neigh_setup
 functions.
Date: Wed, 15 Jan 2014 12:09:52 -0800 (PST)
Message-ID: <20140115.120952.2004059005193691793.davem@davemloft.net>
References: <1389273227-17532-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jes@trained-monkey.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbaAOUJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 15:09:53 -0500
In-Reply-To: <1389273227-17532-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Jan 2014 14:13:47 +0100

> When ndo_neigh_setup is called, the bitfield used by NEIGH_VAR_SET is
> not initialized yet. This might cause confusion for the people who use
> NEIGH_VAR_SET in ndo_neigh_setup. So rather introduce NEIGH_VAR_INIT for
> usage in ndo_neigh_setup.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Jiri, please respond to my feedback, this patch has been rotting in
patchwork for 6 days.
