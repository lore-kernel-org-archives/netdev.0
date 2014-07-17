From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/5][pull request] Intel Wired LAN Driver Updates
 2014-07-16
Date: Wed, 16 Jul 2014 23:54:53 -0700 (PDT)
Message-ID: <20140716.235453.572559572142800647.davem@davemloft.net>
References: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754691AbaGQGyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 02:54:54 -0400
In-Reply-To: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 16 Jul 2014 14:35:29 -0700

> This series contains updates to i40e only.
> 
> Neerav adds support to get the port MAC address from firmware and adds
> support to the ndo_get_phys_port_id() callback to provide port specific
> unique ids to the netdev layer.
> 
> Jakub Kicinski provides 2 fixes, first fixes i40e to never generate a software
> time stamp if the hardware time stamp is provided.  Second fixes a race
> condition on queueing skb for hardware time by using a simple bit lock to
> avoid race conditions and leaking skbs when multiple transmit rings try
> to claim time stamping.
> 
> Paul does some general cleanup of the driver to remove unneeded spaces,
> comments that are no longer valid, and break that will never get touched.
> 
> Jacob Keller adds a verbose warning message when the incorrect PF attempts
> to control timestamping for a port to which it was not assigned.  The primary
> intent of this message is to help debugging the reason why the SIOCSHWSTAMP
> ioctl has failed and to help narrow the cause of the issue.
> 
> The following are changes since commit a84bc2a9013fb123deeca7283480955d021503fb:
>   drivers: net: cpsw: disable coalesce when rx_coalesce_usecs is zero
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, great and informative cover letter as always Jeff, thanks.
