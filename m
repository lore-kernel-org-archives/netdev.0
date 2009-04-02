From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/9] ixgbe: refactor tx buffer processing to use
 skb_dma_map/unmap
Date: Thu, 02 Apr 2009 01:15:49 -0700 (PDT)
Message-ID: <20090402.011549.03175924.davem@davemloft.net>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
	<20090401073423.3749.21206.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com, mallikarjuna.chilakala@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60315
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757409AbZDBIQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:16:01 -0400
In-Reply-To: <20090401073423.3749.21206.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 01 Apr 2009 00:34:23 -0700

> This patch resolves an issue with map single being used to map a buffer and
> then unmap page being used to unmap it.  In addition it handles any error
> conditions that may be detected using skb_dma_map.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
