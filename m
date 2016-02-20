From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V7 0/8] ethtool per queue parameters support
Date: Fri, 19 Feb 2016 22:54:52 -0500 (EST)
Message-ID: <20160219.225452.1370002909860893022.davem@davemloft.net>
References: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bwh@kernel.org, ben@decadent.org.uk,
	andi@firstfloor.org, jesse.brandeburg@intel.com,
	shannon.nelson@intel.com, f.fainelli@gmail.com,
	alexander.duyck@gmail.com, jeffrey.t.kirsher@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net, decot@googlers.com
To: kan.liang@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42214 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1427021AbcBTDy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 22:54:59 -0500
In-Reply-To: <1455891846-12271-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>
Date: Fri, 19 Feb 2016 09:23:58 -0500

> Modern network interface controllers usually support multiple receive
> and transmit queues. Each queue may have its own parameters. For
> example, Intel XL710/X710 hardware supports per queue interrupt
> moderation. However, current ethtool does not support per queue
> parameters option. User has to set parameters for the whole NIC.
> This series extends ethtool to support per queue parameters option.
> 
> Since the support of per queue parameters vary with different cards,
> it is impossible to address all cards in one patch. This series only
> supports per queue coalesce options on i40e driver. The framework used
> in the patch can be easily extended to other cards and parameters.
> 
> The lib bitmap needs to be extended to facilitate exchanging queue bitmaps
> between user space and kernel space. Two patches from David's latest V8
> patch series are also cited in this series. You may refer to
> https://lkml.org/lkml/2016/2/9/919 for more details.
 ...

Series applied, thanks.
