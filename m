From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] ixgbe: update real_num_tx_queues on
 changing num_rx_queues
Date: Tue, 14 Apr 2009 21:54:23 -0700 (PDT)
Message-ID: <20090414.215423.49028564.davem@davemloft.net>
References: <20090415035155.10107.6878.stgit@localhost.localdomain>
	<20090415035217.10107.54118.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, fengguang.wu@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55876
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbZDOEyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:54:32 -0400
In-Reply-To: <20090415035217.10107.54118.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 14 Apr 2009 20:52:17 -0700

> Move the update of real_num_tx_queues from
> ixgbe_acquire_msix_vectors() to ixgbe_set_num_queues(), to ensure it
> be always in sync with num_tx_queues.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
