From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: do not modify tx_queue_len on link speed change
Date: Tue, 23 Mar 2010 23:20:54 -0700 (PDT)
Message-ID: <20100323.232054.209600587.davem@davemloft.net>
References: <20100324043456.32036.21219.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34417
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754799Ab0CXGUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:20:31 -0400
In-Reply-To: <20100324043456.32036.21219.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 23 Mar 2010 21:34:57 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Previously the driver tweaked txqueuelen to avoid false Tx hang reports seen at half duplex.
> This had the effect of overriding user set values on link change/reset. Testing shows that
> adjusting only the timeout factor is sufficient to prevent Tx hang reports at half duplex.
> 
> Based on e1000e patch by Franco Fichtner <franco@lastsummer.de>
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
