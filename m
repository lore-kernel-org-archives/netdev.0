From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/6] net: remove kfree_skb on a NULL pointer in
 af_netlink.c
Date: Thu, 17 Sep 2009 18:24:45 -0700 (PDT)
Message-ID: <20090917.182445.240085155.davem@davemloft.net>
References: <20090918005708.25594.52575.stgit@localhost.localdomain>
	<20090918005729.25594.14261.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	linux-scsi@vger.kernel.org, john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751165AbZIRBY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 21:24:27 -0400
In-Reply-To: <20090918005729.25594.14261.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Sep 2009 17:57:29 -0700

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> This removes a kfree_skb that is being called on a NULL pointer when
> do_one_broadcast() is sucessful.  And moves the kfree_skb into
> do_one_broadcast() for the error case.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

kfree_skb() on a NULL pointer is completely legal.
