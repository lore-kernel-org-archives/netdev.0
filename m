From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] sched: qdisc_reset_all_tx is calling
 qdisc_reset without qdisc_lock
Date: Fri, 02 Jul 2010 21:59:50 -0700 (PDT)
Message-ID: <20100702.215950.104057517.davem@davemloft.net>
References: <20100701232103.15685.48453.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48997
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0GCE7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 00:59:36 -0400
In-Reply-To: <20100701232103.15685.48453.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 01 Jul 2010 16:21:35 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> When calling qdisc_reset() the qdisc lock needs to be held.  In
> this case there is at least one driver i4l which is using this
> without holding the lock.  Add the locking here.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
