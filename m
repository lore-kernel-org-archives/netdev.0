From: David Miller <davem@davemloft.net>
Subject: Re: [net] e100: Add dma mapping error check
Date: Wed, 10 Apr 2013 15:25:54 -0400 (EDT)
Message-ID: <20130410.152554.577565652647867986.davem@davemloft.net>
References: <1365585540-8199-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, jwboyer@redhat.com,
	e1000-devel@lists.sourceforge.net
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933505Ab3DJTZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 15:25:56 -0400
In-Reply-To: <1365585540-8199-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 10 Apr 2013 02:19:00 -0700

> From: Neil Horman <nhorman@tuxdriver.com>
> 
> e100 uses pci_map_single, but fails to check for a dma mapping error after its
> use, resulting in a stack trace:
 ...
> Easy fix, modify the cb paramter to e100_exec_cb to return an error, and do the
> dma_mapping_error check in the obvious place
> 
> This was reported previously here:
> http://article.gmane.org/gmane.linux.network/257893
> 
> But nobody stepped up and fixed it.
> 
> CC: Josh Boyer <jwboyer@redhat.com>
> CC: e1000-devel@lists.sourceforge.net
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Reported-by: Michal Jaegermann <michal@harddata.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
