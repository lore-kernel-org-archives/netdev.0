From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/3] e1000e: fix dma error handling issues
Date: Fri, 20 Mar 2009 01:31:34 -0700 (PDT)
Message-ID: <20090320.013134.113742977.davem@davemloft.net>
References: <20090319111226.11601.40603.stgit@lost.foo-projects.org>
	<20090319111250.11601.23708.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55664
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754712AbZCTIbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 04:31:47 -0400
In-Reply-To: <20090319111250.11601.23708.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 19 Mar 2009 04:12:50 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> There were a few issues I noticed in e1000e. These include a double free
> of the skb if mapping fails, and the fact that context descriptors appear
> to be left in the descriptor ring after the failure.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
