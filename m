From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: Don't allow user buffer count to exceed
 256
Date: Fri, 26 Mar 2010 11:58:20 -0700 (PDT)
Message-ID: <20100326.115820.44147357.davem@davemloft.net>
References: <20100324200204.6384.63977.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, robert.w.love@intel.com,
	yi.zou@intel.com, frank_1.zhang@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50471
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753224Ab0CZS55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 14:57:57 -0400
In-Reply-To: <20100324200204.6384.63977.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 13:02:04 -0700

> From: Robert Love <robert.w.love@intel.com>
> 
> If the user buffer count was 256 the shift would place a 1
> in the offset region leading to errors. It also overwrites
> the uers buffer list. This patch makes sure that at most
> 256 user buffers are allowed for DDP and the buffer count
> is masked properly such that it doesn't overwrite the offset
> when shifting the bits.
> 
> Signed-off-by: Robert Love <robert.w.love@intel.com>
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Signed-off-by: Frank Zhang <frank_1.zhang@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
