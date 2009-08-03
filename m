From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Patch to modify 82598 PCIe completion
 timeout values
Date: Mon, 03 Aug 2009 13:29:44 -0700 (PDT)
Message-ID: <20090803.132944.55626714.davem@davemloft.net>
References: <20090803172037.21652.98159.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33620
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754582AbZHCU3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 16:29:35 -0400
In-Reply-To: <20090803172037.21652.98159.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 03 Aug 2009 10:20:38 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> The default completion timeout values for 82598 should be in the
> range of 50us to 50ms, however the hardware default for these
> parts is 500us to 1ms which is less than the 10ms recommended by
> the pcie spec. To address this we need to increase the value to
> either 10ms to 250ms for capability version 1 configuration, or
> 16ms to 55ms for version 2.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
