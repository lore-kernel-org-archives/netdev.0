From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V1 net-next 0/5] Mellanox ethernet driver update
 Oct-30-2014
Date: Mon, 03 Nov 2014 12:28:48 -0500 (EST)
Message-ID: <20141103.122848.1987980023754200495.davem@davemloft.net>
References: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	saeedm@mellanox.com, shanim@mellanox.com, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbaKCR2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:28:52 -0500
In-Reply-To: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  2 Nov 2014 16:26:12 +0200

> The 1st patch from Saeed fixes a bug in the last net-next batch where
> a VF could get access to set port configuration, the next patch from Amir
> fixes a race in the port VPI logic. Next are two performance patches from Ido.
> 
> The patch to add checksum complete status on GRE and such packets was 
> preceded with a patch that converted the driver to only use napi_gro_receive 
> vs. the current code which goes through napi_gro_frags on it's usual track.
> Eric D. has some thoughts and suggestions on that change for which we 
> want to take the time and consider, so for the time being dropped that
> patch and the ones that depend on it.
 ...
> Changes from V0:
>   - have the caller to provide the __GFP_COLD hint to the service function
>   - dropped the patch that changes the GRO logic and the subsequent dependent
>     patches. 

Series applied, thanks.
