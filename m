From: David Miller <davem@davemloft.net>
Subject: Re: [net] ixgbe: DCB and SR-IOV can not co-exist and will cause
 hangs
Date: Mon, 09 Jul 2012 00:10:24 -0700 (PDT)
Message-ID: <20120709.001024.128106494285303449.davem@davemloft.net>
References: <1341403225-1326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab2GIHKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:10:25 -0400
In-Reply-To: <1341403225-1326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  4 Jul 2012 05:00:25 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> DCB and SR-IOV cannot currently be enabled at the same time as the queueing
> schemes are incompatible.  If they are both enabled it will result in Tx
> hangs since only the first Tx queue will be able to transmit any traffic.
> 
> This simple fix for this is to block us from enabling TCs in ixgbe_setup_tc
> if SR-IOV is enabled.  This change will be reverted once we can support
> SR-IOV and DCB coexistence.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
