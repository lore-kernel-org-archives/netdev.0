From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] e1000e: flow control doesn't re-enable
Date: Thu, 29 Oct 2009 01:05:02 -0700 (PDT)
Message-ID: <20091029.010502.181130396.davem@davemloft.net>
References: <20091029042829.16444.58687.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59221
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752170AbZJ2IEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 04:04:38 -0400
In-Reply-To: <20091029042829.16444.58687.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 28 Oct 2009 21:28:30 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When changing flow control (pause) parameters, the flow control thresholds
> (i.e. when to send XON/XOFF frames) may not be setup correctly on parts
> with copper media.  Call the existing e1000_set_fc_watermarks()
> function to set these thresholds.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
