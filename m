From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] mlxsw: core: Use devm_kzalloc to allocate
 mlxsw_hwmon structure
Date: Tue, 22 Dec 2015 16:25:31 -0500 (EST)
Message-ID: <20151222.162531.1017732977386271974.davem@davemloft.net>
References: <1450773787-2241-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55475 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932620AbbLVVZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:25:36 -0500
In-Reply-To: <1450773787-2241-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 22 Dec 2015 09:43:07 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> KASan reported use-after-free for the hwmon structure. So fix this by
> using devm_kzalloc and let the core take care about freeing the memory
> during device dettach.
> 
> Reported-by: Ido Schimmel <idosch@mellanox.com>
> Fixes: 89309da39 ("mlxsw: core: Implement temperature hwmon interface")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
