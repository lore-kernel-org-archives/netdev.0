From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] 40GbE Intel Wired LAN Driver
 Updates 2017-05-31
Date: Wed, 31 May 2017 17:51:22 -0400 (EDT)
Message-ID: <20170531.175122.944511149075913479.davem@davemloft.net>
References: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45098 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751004AbdEaVyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 17:54:22 -0400
In-Reply-To: <20170531104856.47929-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 31 May 2017 03:48:47 -0700

> This series contains updates to i40e and i40evf only.
> 
> Jesse provides a couple of fixes, starting with cleaning up duplicate
> lines of code.  Fixed a missing line which enables RSS as a negotiated
> feature.  Since the VF does not have any way of reporting FCoE enabled,
> so just force the code to always report FCoE as disabled.
> 
> Jake provides several fixes and changes, starting with fixing a race
> condition in i40e.  The hardware has a limitation on transmit PTP packets,
> which requires us to limit the driver to timestamping a single packet at
> once.  This is done using a state bitlock which enforces that only one
> timestamp request is honored at a time, unfortunately this suffers from
> a race condition.  Fixed a corner case where we failed to cleanup the
> bit lock after a failed transmit, and resulted in a state bit being
> locked forever.  Added a new statistic which tracks when a transmit
> timestamp request is skipped/ignored, since the driver can only handle
> one transmit timestamp request at a time.
> 
> Christophe Jaillet fixes a NULL pointer dereference if kzalloc fails.

Pulled, thanks Jeff.
