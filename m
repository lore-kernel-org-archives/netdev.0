From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: Do not allocate too many
 netdev txqueues
Date: Fri, 26 Feb 2010 02:10:49 -0800 (PST)
Message-ID: <20100226.021049.189355443.davem@davemloft.net>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
	<20100226091519.19796.82441.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	john.r.fastabend@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50663
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932985Ab0BZKKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 05:10:32 -0500
In-Reply-To: <20100226091519.19796.82441.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 26 Feb 2010 01:15:21 -0800

> From: John Fastabend <john.r.fastabend@intel.com>
> 
> Instead of allocating 128 struct netdev_queue per device, use the
> minimum value between 128 and the number of possible txq's, to
> reduce ram usage and "tc -s -d class shod dev .." output.
> 
> This patch fixes Eric Dumazet's patch to set the TX queues to
> the correct minimum.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
