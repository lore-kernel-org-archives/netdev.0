From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] ixgbe: remove CIAA/D register reads from bad
 VF check
Date: Fri, 05 Dec 2014 20:49:56 -0800 (PST)
Message-ID: <20141205.204956.1468623374943582606.davem@davemloft.net>
References: <1417801973-28793-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1417801973-28793-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	alex.williamson@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60028 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbaLFEpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 23:45:43 -0500
In-Reply-To: <1417801973-28793-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  5 Dec 2014 09:52:43 -0800

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Accessing the CIAA/D register can block access to the PCI config space.
> 
> This patch removes the read/write operations to the CIAA/D registers
> and makes use of standard kernel functions for accessing the PCI config
> space.
> 
> In addition it moves ixgbevf_check_for_bad_vf() into the watchdog subtask
> which reduces the frequency of the checks.
> 
> CC: Alex Williamson <alex.williamson@redhat.com>
> Reported-by: Alex Williamson <alex.williamson@redhat.com>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Alex Willaimson stated that he'd like to see this for -stable, but I'm warning
right now that a change not appropriate for 'net' is not approperiate for
'-stable' either.
