From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/9] Introduce devlink interface and first
 drivers to use it
Date: Thu, 25 Feb 2016 15:12:47 -0500 (EST)
Message-ID: <20160225.151247.479900417232368503.davem@davemloft.net>
References: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
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
Received: from shards.monkeyblade.net ([149.20.54.216]:45304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933286AbcBYUMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 15:12:51 -0500
In-Reply-To: <1456242694-29463-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 Feb 2016 16:51:25 +0100

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

I am very close to applying this series as-is.

The clincher for me is that there is precendence in the nl80211 stuff,
so obviously whatever userland infrastructure sits on top of that has
found a way to deal whatever perceived shortcomings devlink has.

If all that people can come up with is "device names! omg UDEV!" and
"multiple tools are hard to use!"  That's awesome, because it means
nobody has any real substantial objection to this facility. :-)
