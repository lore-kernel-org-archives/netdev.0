From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ixgb: refactor tx path to use
 skb_dma_map/unmap
Date: Fri, 20 Mar 2009 01:31:48 -0700 (PDT)
Message-ID: <20090320.013148.111290839.davem@davemloft.net>
References: <20090319111521.11723.60786.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55674
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755502AbZCTIcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:32:01 -0400
In-Reply-To: <20090319111521.11723.60786.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:15:21 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This code updates ixgb so that it can use the skb_dma_map/unmap functions
> to map the buffers.  In addition it also updates the tx hang logic to use
> time_stamp instead of dma to determine if it has detected a tx hang.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
