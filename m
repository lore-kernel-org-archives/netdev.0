From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 02/12] e1000e: bad state after running
 ethtool diagnostics with AMT enabled
Date: Wed, 12 May 2010 23:31:51 -0700 (PDT)
Message-ID: <20100512.233151.112585268.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511005929.30827.30176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45011
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753301Ab0EMGbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:31:43 -0400
In-Reply-To: <20100511005929.30827.30176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 17:59:31 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When running ethtool online diagnostics with no open interface, there is a
> short period of time where the driver relinquishes control of the adapter
> during which time AMT (manageability firmware) can put the adapter into an
> unknown state resulting in such things as link test failure, hardware hang,
> reporting an incorrect link speed, etc.  Resetting the adapter during an
> open() resolves this by putting the adapter into a quiescent state.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
