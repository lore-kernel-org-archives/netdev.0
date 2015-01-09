From: David Miller <davem@davemloft.net>
Subject: Re: [net v2 0/3][pull request] Intel Wired LAN Driver Updates
 2015-01-06
Date: Thu, 08 Jan 2015 19:43:17 -0800 (PST)
Message-ID: <20150108.194317.770869563666169408.davem@davemloft.net>
References: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbbAIDhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:37:33 -0500
In-Reply-To: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  6 Jan 2015 17:31:54 -0800

> This series contains fixes to i40e only.
> 
> Jesse provides a fix for when the driver was polling with interrupts
> disabled the hardware would occasionally not write back descriptors.
> His fix causes the driver to detect this situation and force an interrupt
> to fire which will flush the stuck descriptor.
> 
> Anjali provides a couple of fixes, the first corrects an issue where
> the receive port checksum error counter was incrementing incorrectly with
> UDP encapsulated tunneled traffic.  The second fix resolves an issue where
> the driver was examining the outer protocol layer to set the inner protocol
> layer checksum offload.  In the case of TCP over IPv6 over an IPv4 based
> VXLAN, the inner checksum offloads would be set to look for IPv4/UDP
> instead of IPv6/TCP, so fixed the issue so that the driver will look at
> the proper layer for encapsulation offload settings.
> 
> v2: fixed a bug in patch 01 of the series, where the interrupt rate impacted
>     4 port workloads by reducing throughput.

Pulled, thanks Jeff.
