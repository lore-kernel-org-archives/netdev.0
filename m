From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] forcedeth: updated phy errata
Date: Wed, 02 Sep 2009 23:22:01 -0700 (PDT)
Message-ID: <20090902.232201.248326790.davem@davemloft.net>
References: <4A9C57F5.10800@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754538AbZICGVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 02:21:46 -0400
In-Reply-To: <4A9C57F5.10800@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Mon, 31 Aug 2009 19:08:37 -0400

> This patch updates the special programming (and/or errata) needed in
> order to setup the phy for various vendor models.
> 
> The new models include:
> Marvell E1116
> Marvell E1111
> Marvell E1011
> Marvell E3016
> Broadcom 9507
> Broadcom AC131
> Broadcom 50610
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Please document what these individual bits mean which you
are clearing, by using an individual define for each register
bit to describe it's purpose, and then define the mask as
a concatenation of these bits.

Having an opaque bitmask is not how to do this.

Thanks.
