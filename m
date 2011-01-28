From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 5/7] ixgbe: DDP last buffer size work around
Date: Thu, 27 Jan 2011 22:34:32 -0800 (PST)
Message-ID: <20110127.223432.71105998.davem@davemloft.net>
References: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296195535-2990-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amir.hanania@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44407
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753733Ab1A1Gd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 01:33:57 -0500
In-Reply-To: <1296195535-2990-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 27 Jan 2011 22:18:53 -0800

> From: Amir Hanania <amir.hanania@intel.com>
> 
> We found a hardware erratum on 82599 hardware that can lead to buffer
> overwriting if the last buffer in FCoE DDP is exactly PAGE_SIZE.
> If this is the case, we will make sure that there is no HW access to
> this buffer.
> 
> Please see the 82599 Specification Update for more information.
> 
> Signed-off-by: Amir Hanania <amir.hanania@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

PAGE_SIZE is variable, I can't see how the hardware BUGs on all
possible architecutre values of PAGE_SIZE.
