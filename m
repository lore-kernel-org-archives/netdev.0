From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Only store high 16 bits of kernel generated
 filter priorities
Date: Sat, 02 May 2009 13:48:47 -0700 (PDT)
Message-ID: <20090502.134847.247776351.davem@davemloft.net>
References: <20090502204320.6332.39868.stgit@fritz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: robert.w.love@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751527AbZEBUsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 16:48:52 -0400
In-Reply-To: <20090502204320.6332.39868.stgit@fritz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Love <robert.w.love@intel.com>
Date: Sat, 02 May 2009 13:43:20 -0700

> The kernel should only be using the high 16 bits of a kernel
> generated priority. Filter priorities in all other cases only
> use the upper 16 bits of the u32 'prio' field of 'struct tcf_proto',
> but when the kernel generates the priority of a filter is saves all
> 32 bits which can result in incorrect lookup failures when a filter
> needs to be deleted or modified.
> 
> Signed-off-by: Robert Love <robert.w.love@intel.com>

Applied, thanks Robert!
