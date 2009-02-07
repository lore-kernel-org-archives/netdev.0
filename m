From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ixgbe: Fix a set_num_queues() bug that can
 result in num_(r|t)x_queues = 0
Date: Sat, 07 Feb 2009 02:17:09 -0800 (PST)
Message-ID: <20090207.021709.188305396.davem@davemloft.net>
References: <20090207083257.15354.43853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41718
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751978AbZBGKRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 05:17:13 -0500
In-Reply-To: <20090207083257.15354.43853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 07 Feb 2009 00:33:02 -0800

> Now that our set_num_queues() routines for each feature are re-entrant, and
> can be called at any point, they shouldn't zero out the feature's indices
> or mask bits.  Subsequent calls into those routines for those features can
> result in zero Rx and Tx queues being assigned, causing a panic later in
> driver reinitialization.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
