From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: resolve panic on shutdown when SR-IOV is
 enabled
Date: Wed, 06 May 2009 16:43:57 -0700 (PDT)
Message-ID: <20090506.164357.38216181.davem@davemloft.net>
References: <20090506202749.17405.13051.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752044AbZEFXoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 19:44:01 -0400
In-Reply-To: <20090506202749.17405.13051.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 06 May 2009 13:27:51 -0700

> The setup_rctl call was making a call into the ring structure after it had
> been freed.  This was causing a panic on shutdown.  This call wasn't
> necessary since it is possible to get the needed index from
> adapter->vfs_allocated_count.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks!
