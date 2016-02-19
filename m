From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 0/8] ethtool per queue parameters support
Date: Fri, 19 Feb 2016 15:45:58 -0500 (EST)
Message-ID: <20160219.154558.182059507291320140.davem@davemloft.net>
References: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
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
Received: from shards.monkeyblade.net ([149.20.54.216]:38193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946140AbcBSUqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:46:02 -0500
In-Reply-To: <1455799196-8947-1-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kan Liang <kan.liang@intel.com>
Date: Thu, 18 Feb 2016 07:39:48 -0500

> Modern network interface controllers usually support multiple receive
> and transmit queues. Each queue may have its own parameters. For
> example, Intel XL710/X710 hardware supports per queue interrupt
> moderation. However, current ethtool does not support per queue
> parameters option. User has to set parameters for the whole NIC.
> This series extends ethtool to support per queue parameters option.

This series gets rejects on the i40e changes so you'll have to respin.

Also you are doing the versioning all wrong.

Please do not version all of the patches differently, that's so confusing
and nobody does things like that.

It's the "series" that has a version.

Also you stopped properly updating the changelog in this cover letter
after V5 or so.

Thanks.
