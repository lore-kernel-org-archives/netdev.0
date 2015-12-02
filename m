From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/4] net: support per queue tx_usecs in sysfs
Date: Tue, 01 Dec 2015 21:23:42 -0500 (EST)
Message-ID: <20151201.212342.688373845088380112.davem@davemloft.net>
References: <1448956892-15509-1-git-send-email-kan.liang@intel.com>
	<565E1B8E.4040603@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kan.liang@intel.com, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, jesse.brandeburg@intel.com,
	andi@firstfloor.org, jeffrey.t.kirsher@intel.com,
	shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com,
	john.r.fastabend@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473AbbLBCXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 21:23:48 -0500
In-Reply-To: <565E1B8E.4040603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 01 Dec 2015 14:13:34 -0800

> The new interface you propose makes things inconsistent, since we have
> two separate configuration paths (sysfs and ethtool), and it would seem
> better to have per-queue awareness in ethtool, since there is a whole
> bunch of other parameters that could be configured on a per-queue basis.

Agreed, we have to extend ethtool to support this, in order to provide
a consistent interface.

We could even do this by encapsulating one ethtool command within
another, the outer ethtool command says "apply the inner op to
queue(s) N".
