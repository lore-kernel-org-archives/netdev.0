From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IRDA: Fix global type conflicts in net/irda/irsysctl.c
 v2
Date: Fri, 16 Sep 2011 19:17:40 -0400 (EDT)
Message-ID: <20110916.191740.732077376640568521.davem@davemloft.net>
References: <1316200190-2320-1-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org, ak@linux.intel.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38672 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755850Ab1IPXSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 19:18:52 -0400
In-Reply-To: <1316200190-2320-1-git-send-email-andi@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 16 Sep 2011 12:09:50 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> The externs here didn't agree with the declarations in qos.c.
> 
> Better would be probably to move this into a header, but since it's
> common practice to have naked externs with sysctls I left it for now.
> 
> Cc: samuel@sortiz.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Applied.
