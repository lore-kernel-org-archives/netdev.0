From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] multiq: requeue should rewind the current_band
Date: Sat, 20 Sep 2008 22:08:09 -0700 (PDT)
Message-ID: <20080920.220809.186447283.davem@davemloft.net>
References: <20080919004322.10002.33219.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46216
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750917AbYIUFIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 01:08:21 -0400
In-Reply-To: <20080919004322.10002.33219.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Thu, 18 Sep 2008 17:43:22 -0700

> Currently dequeueing a packet and requeueing the same packet will cause a
> different packet to be pulled on the next dequeue.  This change forces
> requeue to rewind the current_band.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied to net-next-2.6, thanks Alexander.
