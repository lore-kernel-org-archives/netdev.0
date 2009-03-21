From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 5/5] igb: cleanup tx dma so map & unmap use
 matching calls
Date: Sat, 21 Mar 2009 16:57:40 -0700 (PDT)
Message-ID: <20090321.165740.08656569.davem@davemloft.net>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
	<20090320101743.17663.8177.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38444
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754692AbZCUX5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 19:57:52 -0400
In-Reply-To: <20090320101743.17663.8177.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 20 Mar 2009 03:17:43 -0700

> The igb driver was using map_single to map the skbs and then unmap_page to
> unmap them.  This update changes that so instead uses skb_dma_map and
> skb_dma_unmap.
> 
> In addition the next_to_watch member of the buffer_info struct was being
> set uneccesarily.  I removed the spots where it was set without being needed.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
