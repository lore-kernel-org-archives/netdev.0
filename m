From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/3] netdev: Make ethtool_ops::set_flags()
 return -EINVAL for unsupported flags
Date: Wed, 30 Jun 2010 14:10:32 -0700 (PDT)
Message-ID: <20100630.141032.255386379.davem@davemloft.net>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	<1277902016.2082.12.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57478
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203Ab0F3VKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 17:10:18 -0400
In-Reply-To: <1277902016.2082.12.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Jun 2010 13:46:56 +0100

> The documented error code for attempts to set unsupported flags (or
> to clear flags that cannot be disabled) is EINVAL, not EOPNOTSUPP.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
