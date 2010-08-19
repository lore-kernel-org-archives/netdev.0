From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Match underlying dev carrier on vlan add
Date: Thu, 19 Aug 2010 00:27:02 -0700 (PDT)
Message-ID: <20100819.002702.209988778.davem@davemloft.net>
References: <20100818044508.GA23361@linuxace.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kernel@linuxace.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33724
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750999Ab0HSH0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 03:26:43 -0400
In-Reply-To: <20100818044508.GA23361@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Oester <kernel@linuxace.com>
Date: Tue, 17 Aug 2010 21:45:08 -0700

> When adding a new vlan, if the underlying interface has no carrier,
> then the newly added vlan interface should also have no carrier.
> At present, this is not true - the newly added vlan is added with
> carrier up.  Fix by checking state of real device.
> 
> Signed-off-by: Phil Oester <kernel@linuxace.com>

Applied, thanks Phil.
