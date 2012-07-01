From: David Miller <davem@davemloft.net>
Subject: Re: [net] e1000e: remove use of IP payload checksum
Date: Sun, 01 Jul 2012 00:26:06 -0700 (PDT)
Message-ID: <20120701.002606.1838964725740406325.davem@davemloft.net>
References: <1341122562-17382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46750 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649Ab2GAH0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 03:26:17 -0400
In-Reply-To: <1341122562-17382-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 30 Jun 2012 23:02:42 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Currently only used when packet split mode is enabled with jumbo frames,
> IP payload checksum (for fragmented UDP packets) is mutually exclusive with
> receive hashing offload since the hardware uses the same space in the
> receive descriptor for the hardware-provided packet checksum and the RSS
> hash, respectively.  Users currently must disable jumbos when receive
> hashing offload is enabled, or vice versa, because of this incompatibility.
> Since testing has shown that IP payload checksum does not provide any real
> benefit, just remove it so that there is no longer a choice between jumbos
> or receive hashing offload but not both as done in other Intel GbE drivers
> (e.g. e1000, igb).
> 
> Also, add a missing check for IP checksum error reported by the hardware;
> let the stack verify the checksum when this happens.
> 
> CC: stable <stable@vger.kernel.org> [3.4]
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
