From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30] cxgb3: clear shadow BAR registers
Date: Tue, 31 Mar 2009 20:34:57 -0700 (PDT)
Message-ID: <20090331.203457.210552824.davem@davemloft.net>
References: <20090401005854.15175.44595.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35697
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754833AbZDADfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 23:35:09 -0400
In-Reply-To: <20090401005854.15175.44595.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Tue, 31 Mar 2009 17:58:54 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> Ensure that internal shadow BAR registers are cleared on 32-bit platforms.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Why is this a problem and why is it not possible to rely
on these being setup to zero by either the BIOS or the PCI
layer?

At best this is a PCI quirk and not something that belongs
in the driver.

I'm not applying this.
