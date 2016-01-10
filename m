From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/8] mlxsw: Adding layer 2 multicast
Date: Sun, 10 Jan 2016 16:50:43 -0500 (EST)
Message-ID: <20160110.165043.989685332501427292.davem@davemloft.net>
References: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58380 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756818AbcAJVuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 16:50:50 -0500
In-Reply-To: <1452456389-2833-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun, 10 Jan 2016 21:06:21 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Elad says:
> 
> This patchset add Linux hardware reflection for L2 multicast offload and add
> MC support in mlxsw. For every bridge MDB entry insertion, either by IGMP
> snooping or by static insertion/removal, a switchdev ops is been called.
> In mlxsw, a new multicast group (MID) is been created and ports are assigned.
> When all ports are removed, the multicast group is been deleted.
> 
> ---
> v1->v2:
> - GFP_ATOMIC->GFP_KERNEL change in patch 7/8

Series applied, thanks Jiri!
