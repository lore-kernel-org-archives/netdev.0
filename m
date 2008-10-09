From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 1/2] e1000e: don't generate bad checksums for
 tcp packets with 0 csum
Date: Thu, 09 Oct 2008 14:29:36 -0700 (PDT)
Message-ID: <20081009.142936.00354103.davem@davemloft.net>
References: <20081009165831.32435.81922.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, david.graham@intel.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753527AbYJIVaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:30:00 -0400
In-Reply-To: <20081009165831.32435.81922.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 09 Oct 2008 09:58:31 -0700

> When offloading transmit checksums only, the driver was not
> correctly configuring the hardware to handle the case of a zero
> checksum.  For UDP the correct behavior is to leave it alone, but
> for tcp the checksum must be changed from 0x0000 to 0xFFFF.  The
> hardware takes care of this case but only if it is told the
> packet is tcp.
> 
> Signed-off-by: Dave Graham <david.graham@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
