From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: do not modify tx_queue_len on link speed change
Date: Fri, 26 Mar 2010 21:05:48 -0700 (PDT)
Message-ID: <20100326.210548.159279832.davem@davemloft.net>
References: <20100324225501.7104.28849.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, franco@lastsummer.de,
	emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37276
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0C0EF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 00:05:26 -0400
In-Reply-To: <20100324225501.7104.28849.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 15:55:02 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Previously the driver tweaked txqueuelen to avoid false Tx hang reports seen at half duplex.
> This had the effect of overriding user set values on link change/reset. Testing shows that
> adjusting only the timeout factor is sufficient to prevent Tx hang reports at half duplex.
> 
> This patch removes all instances of tx_queue_len in the driver.
> 
> Originally reported and patched by Franco Fichtner
> CC: Franco Fichtner <franco@lastsummer.de>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-2.6
