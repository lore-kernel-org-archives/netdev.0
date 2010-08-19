From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] e1000e: don't check for alternate MAC addr
 on parts that don't support it
Date: Thu, 19 Aug 2010 15:49:04 -0700 (PDT)
Message-ID: <20100819.154904.71093624.davem@davemloft.net>
References: <20100819224307.10079.89643.stgit@localhost.localdomain>
	<20100819224410.10079.31067.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	bruce.w.allan@intel.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42345
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752826Ab0HSWsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 18:48:47 -0400
In-Reply-To: <20100819224410.10079.31067.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Aug 2010 15:44:11 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The alternate MAC address feature is only supported by 80003ES2LAN and
> 82571 LOMs as well as a couple 82571 mezzanine cards.  Checking for an
> alternate MAC address on other parts can fail leading to the driver not
> able to load.  This patch limits the check for an alternate MAC address
> to be done only for parts that support the feature.
> 
> This issue has been around since support for the feature was introduced
> to the e1000e driver in 2.6.34.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Reported-by: Fabio Varesano <fax8@users.sourceforge.net>
> Cc: stable@kernel.org
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
