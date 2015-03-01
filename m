From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 09/18] i40e/i40evf: Add capability to gather VEB per
 TC stats
Date: Sat, 28 Feb 2015 23:30:43 -0500 (EST)
Message-ID: <20150228.233043.1806944010152525182.davem@davemloft.net>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1425122989-354-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: neerav.parikh@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbbCAEax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 23:30:53 -0500
In-Reply-To: <1425122989-354-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 28 Feb 2015 03:29:40 -0800

> From: Neerav Parikh <neerav.parikh@intel.com>
> 
> This patch adds capability to update per VEB per TC statistics and dump
> it via debugfs. It also adds a structure to hold VEB per TC statistics.
> The fields can be filled by reading the GLVEBTC_* counters.
> 
> Change-ID: I45cca003d8b12d96951a67f50d5dd7a789e09218
> Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

For the umpteenth time, stop dumping statistics into debugfs.

Export them like any other statistic, via ethtool.

This applies to the existing debugfs you're building on top
of in this change as well, I very much regret not catching
that when it initially went in.

Please stop, in general, using debugfs as a dumping ground
for thing you can't initially figure out how to export via
normal standard interfaces.
