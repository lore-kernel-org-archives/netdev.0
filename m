From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] vxge: hotplug stall
Date: Fri, 10 Dec 2010 16:09:15 -0800 (PST)
Message-ID: <20101210.160915.90793925.davem@davemloft.net>
References: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
	<1292025782-16372-5-git-send-email-jon.mason@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sivakumar.subramani@exar.com,
	sreenivasa.honnur@exar.com, ram.vepa@exar.com
To: jon.mason@exar.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756691Ab0LKAIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:08:48 -0500
In-Reply-To: <1292025782-16372-5-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jon.mason@exar.com>
Date: Fri, 10 Dec 2010 18:03:00 -0600

> When hot-unplugging a vxge adapter while running, the driver's remove
> routine prints warning and then stalls the calling thread.  This is due
> to vxge_remove calling vxge_device_unregister to unregister the netdev
> before calling flush_scheduled_work clear any pending work.  Swapping
> the order of these two functions resolves the issue.
> 
> Signed-off-by: Jon Mason <jon.mason@exar.com>
> Signed-off-by: Ram Vepa <ram.vepa@exar.com>

Applied.
