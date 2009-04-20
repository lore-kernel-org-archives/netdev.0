From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30 1/4] cxgb3: fix link fault handling
Date: Mon, 20 Apr 2009 02:08:11 -0700 (PDT)
Message-ID: <20090420.020811.133077999.davem@davemloft.net>
References: <20090417222111.8472.45439.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752152AbZDTJIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 05:08:20 -0400
In-Reply-To: <20090417222111.8472.45439.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Fri, 17 Apr 2009 15:21:11 -0700

> Use the existing periodic task to handle link faults.
> The link fault interrupt handler is also called in work queue context,
> which is wrong and might cause potential deadlocks.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
