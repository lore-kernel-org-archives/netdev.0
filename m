From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 2/2] mlxsw: spectrum: remove FDB entry in
 case we get unknown object notification
Date: Sat, 09 Jan 2016 21:07:08 -0500 (EST)
Message-ID: <20160109.210708.1566592679545936608.davem@davemloft.net>
References: <1452163830-20425-1-git-send-email-jiri@resnulli.us>
	<1452163830-20425-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756707AbcAJCHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 21:07:10 -0500
In-Reply-To: <1452163830-20425-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  7 Jan 2016 11:50:30 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> It may happen that we get notification for FDB entry for object (port,
> lag, vport), which does not exist. Currently we ignore that, which only
> causes this being re-sent in next notification. The entry will never
> disappear. So get rid of it by simply removing it using SFD register.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> ---
> v1->v2:
> - fixing impossible mlxsw_sp_port null dereference

Applied.
