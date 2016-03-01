From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 0/9] Introduce devlink interface and first
 drivers to use it
Date: Tue, 01 Mar 2016 16:08:09 -0500 (EST)
Message-ID: <20160301.160809.1004237629125677684.davem@davemloft.net>
References: <1456504351-18871-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com, hannes@stressinduktion.org,
	gospo@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbcCAVIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 16:08:13 -0500
In-Reply-To: <1456504351-18871-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 Feb 2016 17:32:22 +0100

> There a is need for some userspace API that would allow to expose things
> that are not directly related to any device class like net_device of
> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
> 
> Use cases:
> 1) get/set of port type (Ethernet/InfiniBand)
> 2) setting up port splitters - split port into multiple ones and squash again,
>    enables usage of splitter cable
> 3) setting up shared buffers - shared among multiple ports within
>    one chip (work in progress)
> 4) configuration of switch wide properties - resources division etc - This will
>    allow to pass configuration that is unacceptable to be passed as
>    a module option.
> 
> First patch of this set introduces a new generic Netlink based interface,
> called "devlink". It is similar to nl80211 model and it is heavily
> influenced by it, including the API definition. The devlink introduction patch
> implements use cases 1) and 2). Other 2 are in development atm and will
> be addressed by follow-ups.
> 
> It is very convenient for drivers to use devlink, as you can see in other
> patches in this set.
> 
> Counterpart for devlink is userspace tool for now called "dl". Command line
> interface and outputs are derived from "ip" tool so it should be easy
> for users to get used to it.
> 
> It is available here as a standalone tool for now:
> https://github.com/jpirko/devlink
> After this is merge in kernel, I will include the "dl" or "devlink" tool
> into iproute2 toolset.
 ...

Series applied, thanks Jiri.
