From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] e1000: cleanup clean_tx_irq routine so
 that it completely cleans ring
Date: Thu, 26 Mar 2009 01:02:03 -0700 (PDT)
Message-ID: <20090326.010203.96337843.davem@davemloft.net>
References: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
	<20090326075904.30121.89432.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44068
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756076AbZCZICP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 04:02:15 -0400
In-Reply-To: <20090326075904.30121.89432.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Mar 2009 00:59:04 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> The tx cleanup routine was stopping after 64 packets and this was causing
> issues resulting in the ring not being completely cleaned.
> 
> This change updates the driver to clean the entire ring and if it doesn't
> it then will retry on the next pass.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
