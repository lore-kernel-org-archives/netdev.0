From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/4] e1000e: avoid polling h/w registers
 during link negotiation
Date: Mon, 21 Jun 2010 13:43:01 -0700 (PDT)
Message-ID: <20100621.134301.104067615.davem@davemloft.net>
References: <20100618045804.6728.37945.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52927
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752828Ab0FUUmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:42:49 -0400
In-Reply-To: <20100618045804.6728.37945.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Jun 2010 21:58:43 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> Avoid touching hardware registers when possible, otherwise link negotiation
> can get messed up when user-level scripts are rapidly polling the driver to
> see if/when link is up.  Use the saved link state information instead when
> possible.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
