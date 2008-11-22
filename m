From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 06/14] e1000e: remove unnecessary header file
 inclusions
Date: Fri, 21 Nov 2008 16:53:21 -0800 (PST)
Message-ID: <20081121.165321.258216507.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190035.32313.26432.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42267
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752250AbYKVAxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:53:22 -0500
In-Reply-To: <20081121190035.32313.26432.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:00:35 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> timer.h and workqueue.h do not need to be explicitly included.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

You are using "struct timer_list" et al. in this header file so
you do in fact need to include these header files.

If the idea is to rely upon getting these headers indirectly,
that's not how things work.

Not applied.
