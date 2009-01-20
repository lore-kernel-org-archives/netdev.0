From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] ixgbe: fix tag stripping for VLAN ID 0
Date: Mon, 19 Jan 2009 16:55:23 -0800 (PST)
Message-ID: <20090119.165523.139258618.davem@davemloft.net>
References: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
	<20090120001126.22544.65196.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	donald.c.skidmore@intel.com, peter.p.waskiewicz.jr@intel.com,
	eric.w.multanen@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43270
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754242AbZATAzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:55:22 -0500
In-Reply-To: <20090120001126.22544.65196.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jan 2009 16:11:26 -0800

> Register VLAN ID 0 so that frames with VLAN ID 0 are received and get their tag stripped when ixgbe is not in DCB mode.  VLAN ID 0 means that the frame is 'priority tagged' only - it is not a VLAN, but the priority value is the tag in valid.  The functions ixgbe_vlan_rx_register() and
> ixgbe_vlan_rx_kill_vid() were moved up a couple functions to correct compiling issues with this change.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Eric W Multanen <eric.w.multanen@intel.com>

Applied.
