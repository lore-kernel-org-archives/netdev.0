From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/3] igb: simplify swap in clean_rx_irq if
 using packet split
Date: Thu, 20 Nov 2008 00:47:40 -0800 (PST)
Message-ID: <20081120.004740.251084820.davem@davemloft.net>
References: <20081118020510.10912.94106.stgit@gitlost.lost>
	<20081118020531.10912.66635.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52488
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753867AbYKTIrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:47:40 -0500
In-Reply-To: <20081118020531.10912.66635.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Nov 2008 18:05:31 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This update replaces the xchg calls that were added with a pair of
> assignments as there is no need for the xchg calls and they were found to
> cause issues on some architectures.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
