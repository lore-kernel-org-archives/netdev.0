From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 3/3] NET/ixgbe: Fix powering off during shutdown
Date: Thu, 16 Apr 2009 02:16:24 -0700 (PDT)
Message-ID: <20090416.021624.192267717.davem@davemloft.net>
References: <20090416034323.14634.30701.stgit@localhost.localdomain>
	<20090416034401.14634.77826.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, rjw@sisk.pl
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43272
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752968AbZDPJQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 05:16:33 -0400
In-Reply-To: <20090416034401.14634.77826.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 15 Apr 2009 20:44:01 -0700

> Prevent ixgbe from putting the adapter into D3 during shutdown except when
> we're going to power off the system, since doing that may generally cause
> problems with kexec to happen (such problems were observed for igb and
> forcedeth).  For this purpose seperate ixgbe_shutdown() from ixgbe_suspend()
> and use the appropriate PCI PM callbacks in both of them.
> 
> Signed-off-by: "Rafael J. Wysocki" <rjw@sisk.pl>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
