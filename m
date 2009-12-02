From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/9] e1000e: provide family-specific PHY
 power up/down operations
Date: Wed, 02 Dec 2009 00:37:49 -0800 (PST)
Message-ID: <20091202.003749.173515426.davem@davemloft.net>
References: <20091202014641.396.57708.stgit@localhost.localdomain>
	<20091202014720.396.29751.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754796AbZLBIhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 03:37:43 -0500
In-Reply-To: <20091202014720.396.29751.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 01 Dec 2009 17:47:22 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The different families (80003es2lan, 8257x, ICHx/PCH) supported by the
> driver each have their own conditions when the PHY can be powered down.
> This patch rewrites the PHY power up/down code to fit with the family-
> specific style used in the driver.  All pre-existing calls to power up or
> down the PHY remain untouched.  A new call to power down the PHY when
> removing the driver when the interface is down replaces the current call
> to reset the PHY in order to reduce power consumption.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
