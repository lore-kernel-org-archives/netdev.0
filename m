From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 1/2] mlxsw: spectrum: pass local_port to
 mlxsw_sp_port_fdb_uc_op
Date: Sat, 09 Jan 2016 21:07:01 -0500 (EST)
Message-ID: <20160109.210701.2226572713009411405.davem@davemloft.net>
References: <1452163830-20425-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756607AbcAJCHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 21:07:04 -0500
In-Reply-To: <1452163830-20425-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  7 Jan 2016 11:50:29 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Do not pass struct mlxsw_sp_port to mlxsw_sp_port_fdb_uc_op and rather
> just pass local_port. This is needed in case this is called from SFN
> process function and mlxsw_sp_port is not existent for particular
> local_port.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> ---
> v1->v2:
> - no change

Applied.
