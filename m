From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] ixgbe: fix for link failure on SFP+
 DA cables
Date: Mon, 06 Dec 2010 13:21:23 -0800 (PST)
Message-ID: <20101206.132123.112593518.davem@davemloft.net>
References: <20101203232218.21869.62349.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40174
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753681Ab0LFVU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:20:56 -0500
In-Reply-To: <20101203232218.21869.62349.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 03 Dec 2010 15:23:30 -0800

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> This patch helps prevent FW/SW semaphore collision from leading
> to link establishment failure.  The collision might mess up the
> PHY registers so we reset the PHY.  However there are SFI/KR areas
> in the PHY that are not reset with a Reset_AN so we need to change
> LMS to reset it.  Also wait until AN state machine is AN_GOOD
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
