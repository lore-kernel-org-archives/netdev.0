From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
 2015-07-17
Date: Mon, 20 Jul 2015 20:50:35 -0700 (PDT)
Message-ID: <20150720.205035.664905720168689836.davem@davemloft.net>
References: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbGUDug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 23:50:36 -0400
In-Reply-To: <1437143123-5031-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 17 Jul 2015 07:25:09 -0700

> This series contains updates to igb, ixgbe, ixgbevf, i40e, bnx2x,
> freescale, siena and dp83640.
> 
> Jacob provides several patches to clarify the intended way to implement
> both SIOCSHWTSTAMP and ethtool's get_ts_info().  It is okay to support
> the specific filters in SIOCSHWTSTAMP by upscaling them to the generic
> filters.
> 
> Alex Duyck provides a igb patch to pull the time stamp from the fragment
> before it gets added to the skb, to avoid a possible issue in which the
> fragment can possibly be less than IGB_RX_HDR_LEN due to the time stamp
> being pulled after the copybreak check.  Also provides a ixgbevf patch to
> fold the ixgbevf_pull_tail() call into ixgbevf_add_rx_frag(), which gives
> the advantage that the fragment does not have to be modified after it is
> added to the skb.
> 
> Fan provides patches for ixgbe/ixgbevf to set the receive hash type
> based on receive descriptor RSS type.
> 
> Todd provides a fix for igb where on check for link on any media other
> than copper was not being detected since it was looking on the incorrect
> PHY page (due to the page being used gets switched before the function
> to check link gets executed).

Pulled, thanks a lot Jeff.
