From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 38 of 39] IB/ipath - More changes to support InfiniPath on PowerPC 970 systems
Date: Tue, 4 Jul 2006 08:25:06 +1000
Message-ID: <20060703222506.GD31081@krispykreme>
References: <c22b6c244d5db77f7b1d.1151617289@eng-12.pathscale.com> <20060629.145319.71091846.davem@davemloft.net> <1151618499.10886.26.camel@chalcedony.pathscale.com> <20060629.150417.78710870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bos@pathscale.com, akpm@osdl.org, rdreier@cisco.com,
	mst@mellanox.co.il, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	matthew@wil.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:48305 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1750834AbWGCW1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:27:23 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060629.150417.78710870.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
Hi,

> Please fix the generic code if it doesn't provide the facility
> you need at the moment.  Don't shoe horn it into your driver
> just to make up for that.

Ive had 3 drivers asking for write combining recently so I agree this is
a good idea. How about ioremap_wc as suggested by Willy:

http://marc.theaimsgroup.com/?l=linux-kernel&m=114374741828040&w=2

Anton
