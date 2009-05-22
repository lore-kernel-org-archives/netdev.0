From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] igb: do not re-register DCA requester
 on device reset
Date: Thu, 21 May 2009 17:20:50 -0700 (PDT)
Message-ID: <20090521.172050.128182585.davem@davemloft.net>
References: <20090521230639.21776.59261.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752228AbZEVAUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 20:20:51 -0400
In-Reply-To: <20090521230639.21776.59261.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 May 2009 16:06:56 -0700

> The current driver is re-registering the DCA requester after every reset.
> Instead of doing this we should only be updating the on board DCA registers
> and not unregistering/re-registering our requester.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
