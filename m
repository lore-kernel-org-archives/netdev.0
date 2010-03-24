From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: count Rx FIFO errors correctly
Date: Tue, 23 Mar 2010 23:20:47 -0700 (PDT)
Message-ID: <20100323.232047.11981843.davem@davemloft.net>
References: <20100324043437.32036.44229.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mitch.a.williams@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34411
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754799Ab0CXGUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 02:20:24 -0400
In-Reply-To: <20100324043437.32036.44229.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 23 Mar 2010 21:34:38 -0700

> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> Don't aggregate rx_no_buffer_count into rx_fifo_errors. RNBC counts
> packets that get queued temporarily in the adapter's FIFO. These
> packets are not dropped and are not errors. The correct counter
> is rx_missed_errors (MPC).
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
