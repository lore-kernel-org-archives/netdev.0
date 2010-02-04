From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: make certain to reassign legacy interrupt
 vectors after reset
Date: Thu, 04 Feb 2010 09:49:40 -0800 (PST)
Message-ID: <20100204.094940.98184357.davem@davemloft.net>
References: <20100204075925.16897.84090.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093Ab0BDRt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 12:49:27 -0500
In-Reply-To: <20100204075925.16897.84090.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 03 Feb 2010 23:59:51 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change corrects an issue that will cause false hangs when using either
> 82575 or 82580 in legacy interrupt mode.  The issue is caused when there is
> a slow traffic flow and an "ethtool -r" is executed while using legacy or
> MSI interrupts.  MSI-X is not affected by this issue due to the fact that
> we were already reconfiguring the vectors after reset.
> 
> If possible it would be best to push this for net-2.6 since it is resolving
> a bug but if that is not possible then net-next-2.6 will be fine.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
