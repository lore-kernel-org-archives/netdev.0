From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] switchdev: bridge: Pass ageing time as clock_t
 instead of jiffies
Date: Tue, 22 Dec 2015 15:57:25 -0500 (EST)
Message-ID: <20151222.155725.1522363587231289331.davem@davemloft.net>
References: <1450688161-4792-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, stephen@networkplumber.org, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbbLVU51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 15:57:27 -0500
In-Reply-To: <1450688161-4792-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 21 Dec 2015 09:56:01 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> The bridge's ageing time is offloaded to hardware when:
> 	1) A port joins a bridge
> 	2) The ageing time of the bridge is changed
> 
> In the first case the ageing time is offloaded as jiffies, but in the
> second case it's offloaded as clock_t, which is what existing switchdev
> drivers expect to receive.
> 
> Fixes: 6ac311ae8bfb ("Adding switchdev ageing notification on port bridged")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied and queued up for -stable, thanks!
