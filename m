From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] ixgbe: fix TX ring enable issues seen
 when VMDQ is enabled
Date: Wed, 08 Sep 2010 21:41:41 -0700 (PDT)
Message-ID: <20100908.214141.58417891.davem@davemloft.net>
References: <20100908073229.722.61015.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751047Ab0IIElX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 00:41:23 -0400
In-Reply-To: <20100908073229.722.61015.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 08 Sep 2010 00:34:29 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The ordering of operations was messed up in the init and as a result when
> VMDQ was enabled we were trying to enable TX rings before setting the VFTE
> bits. This resulted in a ring that appeared to fail to enable when in fact
> it was blocked because the VFTE bits were cleared after the reset.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
