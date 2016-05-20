From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] Follow-ups for GUEoIPv6 patches
Date: Fri, 20 May 2016 19:26:17 -0400 (EDT)
Message-ID: <20160520.192617.407123677086722342.davem@davemloft.net>
References: <20160518173605.2608.42484.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, alexander.duyck@gmail.com,
	intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kernel-team@fb.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbcETX0T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:26:19 -0400
In-Reply-To: <20160518173605.2608.42484.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Wed, 18 May 2016 10:44:40 -0700

> This patch series is meant to be applied after:
> [PATCH v7 net-next 00/16] ipv6: Enable GUEoIPv6 and more fixes for v6 tunneling
> 
> The first patch addresses an issue we already resolved in the GREv4 and is
> now present in GREv6 with the introduction of FOU/GUE for IPv6 based GRE
> tunnels.
> 
> The second patch goes through and enables IPv6 tunnel offloads for the Intel
> NICs that already support the IPv4 based IP-in-IP tunnel offloads.  I have
> only done a bit of touch testing but have seen ~20 Gb/s over an i40e
> interface using a v4-in-v6 tunnel, and I have verified IPv6 GRE is still
> passing traffic at around the same rate.  I plan to do further testing but
> with these patches present it should enable a wider audience to be able to
> test the new features introduced in Tom's patchset with hardware offloads.

Series applied, thanks Alex.
