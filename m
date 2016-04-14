From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/18] devlink + mlxsw: add support for config
 and control of shared buffers
Date: Thu, 14 Apr 2016 15:21:56 -0400 (EDT)
Message-ID: <20160414.152156.2049059347507873710.davem@davemloft.net>
References: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40316 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753299AbcDNTWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:22:00 -0400
In-Reply-To: <1460650770-19382-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 14 Apr 2016 18:19:12 +0200

> ASICs implement shared buffer for packet forwarding purposes and enable
> flexible partitioning of the shared buffer for different flows and ports,
> enabling non-blocking progress of different flows as well as separation
> of lossy traffic from loss-less traffic when using Per-Priority Flow
> Control (PFC). The shared buffer optimizes the buffer utilization for better
> absorption of packet bursts.
> 
> This patchset implements API which is based on the model SAI uses. That is
> aligned with multiple ASIC vendors so this API should be vendor neutral.
> 
> Userspace counterpart patchset for devlink iproute2 tool can be found here:
> https://github.com/jpirko/iproute2_mlxsw/tree/devlink_sb
> 
> Couple of examples of usage:
 ...

This looks really nice to me, series applied, thanks Jiri.
