From: David Miller <davem@davemloft.net>
Subject: Re: [net] net: Fix memory leak - vlan_info struct
Date: Tue, 10 Jul 2012 23:36:51 -0700 (PDT)
Message-ID: <20120710.233651.97700112989188430.davem@davemloft.net>
References: <1341902839-13181-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amir.hanania@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab2GKGgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 02:36:52 -0400
In-Reply-To: <1341902839-13181-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  9 Jul 2012 23:47:19 -0700

> From: Amir Hanania <amir.hanania@intel.com>
> 
> In driver reload test there is a memory leak.
> The structure vlan_info was not freed when the driver was removed.
> It was not released since the nr_vids var is one after last vlan was removed.
> The nr_vids is one, since vlan zero is added to the interface when the interface
> is being set, but the vlan zero is not deleted at unregister.
> Fix - delete vlan zero when we unregister the device.
> 
> Signed-off-by: Amir Hanania <amir.hanania@intel.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied and queued up for -stable, thanks.
