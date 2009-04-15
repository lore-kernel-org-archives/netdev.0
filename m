From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] ixgbe: fix tx queue index
Date: Tue, 14 Apr 2009 21:54:15 -0700 (PDT)
Message-ID: <20090414.215415.77558705.davem@davemloft.net>
References: <20090415035155.10107.6878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, fengguang.wu@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55872
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751004AbZDOEyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 00:54:25 -0400
In-Reply-To: <20090415035155.10107.6878.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 14 Apr 2009 20:51:58 -0700

> Don't do the num_tx_queues based masking on calculating tx queue
> index.
> 
>  1) num_tx_queues is not always power-of-2, because it also depends on
>     the online cpu numbers. So the masking could be a performance bug
>     on a 6 cpu system.
>  2) queue_mapping will be limited by real_num_tx_queues=num_tx_queues
>     in the generic netdev function set_cur_queue_map(). So the bound
>     limiting here is not necessary.
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
