From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/15][pull request] 100GbE Intel Wired LAN
 Driver Updates 2016-04-05
Date: Tue, 05 Apr 2016 16:09:17 -0400 (EDT)
Message-ID: <20160405.160917.2081917895271656450.davem@davemloft.net>
References: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33432 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718AbcDEUJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 16:09:20 -0400
In-Reply-To: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  5 Apr 2016 13:02:12 -0700

> This series contains updates to fm10k only.
> 
> Bruce provides nearly half of the patches in the series, most of which do
> general cleanup of the driver.  These include semantic cleanups,
> checkpatch.pl fixes, update driver to use BIT() kernel macro, use
> BUILD_BUG_ON() where appropriate and use ether_addr_copy() instead of
> memcpy().
> 
> Jake provides the remaining patches in the series, starting with a fix
> for a possible NULL pointer deference.  Next delays initialization of the
> service timer and service task until late in probe().  If we do not wait,
> failures in probe do not properly cleanup the service timer or service
> task items which result in a kernel panic.  Added better reporting during
> error conditions.  Fixed another possible kernel panic where we were
> clearing the interrupt scheme before we freed the mailbox IRQ.  Added
> helper functions for setting strings and data for ethtool stats.  Fixed
> comment mis-spelled words.
> 
> v2: Dropped patch 3 from the original submission, until a better solution
>     can be worked up based on feedback from Joe Perches and David Miller.

Pulled, thanks Jeff.
