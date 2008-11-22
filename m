From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 08/14] e1000e: link up/down messages must
 follow a specific format
Date: Fri, 21 Nov 2008 16:55:33 -0800 (PST)
Message-ID: <20081121.165533.101574532.davem@davemloft.net>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190110.32313.43591.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46651
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757894AbYKVAze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:55:34 -0500
In-Reply-To: <20081121190110.32313.43591.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 21 Nov 2008 11:01:10 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The system log messages created on a link status change need to follow a
> specific format to work with tools some customers use.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

As stated by others, if anything we should have a global tree wide
format for this.  Even via a helper function or similar.

But for now, how you print this message is your business, so
patch applied :)
