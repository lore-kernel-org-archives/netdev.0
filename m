From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: pci: Adjust value of CPU egress
 traffic class
Date: Wed, 06 Jan 2016 00:49:25 -0500 (EST)
Message-ID: <20160106.004925.679146000360471465.davem@davemloft.net>
References: <1451990200-2356-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbcAFFt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 00:49:27 -0500
In-Reply-To: <1451990200-2356-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  5 Jan 2016 11:36:40 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> During initialization, when creating the send descriptor queues (SDQs),
> we specify the CPU egress traffic class of each SDQ. The maximum number
> of classes of this type is different in the two ASICs supported by this
> PCI driver.
> 
> New firmware versions check this value is set correctly, which causes
> errors on the Spectrum ASIC, as its max exposed egress traffic class is
> lower than 7.
> 
> Solve this by setting this field to 3, which is an acceptable value for
> both ASICs.
> 
> Note that we currently do not expose the QoS capabilities of the ASICs,
> so setting this to an hardcoded value is OK for now.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
