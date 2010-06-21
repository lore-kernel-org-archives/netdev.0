From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] e1000e: packet split should not be
 used with early receive
Date: Mon, 21 Jun 2010 13:43:15 -0700 (PDT)
Message-ID: <20100621.134315.112590520.davem@davemloft.net>
References: <20100618045804.6728.37945.stgit@localhost.localdomain>
	<20100618045925.6728.43858.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52938
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758370Ab0FUUnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:43:02 -0400
In-Reply-To: <20100618045925.6728.43858.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Jun 2010 21:59:27 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Originally it was thought there were issues with ICHx/PCH parts with packet
> split when jumbo frames were enabled but in fact it is really only when
> early-receive is enabled (via ERT register) on these parts.  Use packet
> split with jumbos but only when early-receive is not enabled.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
