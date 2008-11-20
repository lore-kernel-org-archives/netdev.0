From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 3/3] igb: Fix tx/rx_ring_count parameters for
 igb on suspend/resume/ring resize
Date: Thu, 20 Nov 2008 00:48:17 -0800 (PST)
Message-ID: <20081120.004817.28562296.davem@davemloft.net>
References: <20081118020510.10912.94106.stgit@gitlost.lost>
	<20081118020550.10912.1643.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52492
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753887AbYKTIsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:48:17 -0500
In-Reply-To: <20081118020550.10912.1643.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Nov 2008 18:05:50 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> When suspending the device the ring structure is freed which causes it to
> loose track of the count.  To resolve this we need to move the ring count
> outside of the ring structure and store it in the adapter struct.
> 
> In addition to resolving the suspend/resume issue this patch also addresses
> issues seen in the event of memory allocation errors causing uneven ring
> sizes on multiple queues.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
