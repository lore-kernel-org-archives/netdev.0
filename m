From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] bridge: switchdev: Offload VLAN flags to
 hardware bridge
Date: Thu, 18 Feb 2016 11:18:32 -0500 (EST)
Message-ID: <20160218.111832.1197390152083718401.davem@davemloft.net>
References: <1455800506-13190-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946584AbcBRQSe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 11:18:34 -0500
In-Reply-To: <1455800506-13190-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 18 Feb 2016 14:01:46 +0100

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When VLANs are created / destroyed on a VLAN filtering bridge (MASTER
> flag set), the configuration is passed down to the hardware. However,
> when only the flags (e.g. PVID) are toggled, the configuration is done
> in the software bridge alone.
> 
> While it is possible to pass these flags to hardware when invoked with
> the SELF flag set, this creates inconsistency with regards to the way
> the VLANs are initially configured.
> 
> Pass the flags down to the hardware even when the VLAN already exists
> and only the flags are toggled.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks guys.
