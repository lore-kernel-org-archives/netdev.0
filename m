From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH 2/2] igb: loopback bits not correctly cleared
 from RCTL register
Date: Tue, 25 Nov 2008 01:04:09 -0800 (PST)
Message-ID: <20081125.010409.105729069.davem@davemloft.net>
References: <20081124234845.24515.6891.stgit@gitlost.lost>
	<20081124234903.24515.58872.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46221
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbYKYJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 04:04:10 -0500
In-Reply-To: <20081124234903.24515.58872.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 24 Nov 2008 15:49:03 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change forces the bits to 0 by using an &= operation with an inverted
> mask of all options instead of using an |= with a value of 0.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
