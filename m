From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: send host-name in DHCP requests
Date: Wed, 02 Jun 2010 07:05:31 -0700 (PDT)
Message-ID: <20100602.070531.73368509.davem@davemloft.net>
References: <20100531031953.GA10590@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	andi@firstfloor.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44639
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757632Ab0FBOFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:05:21 -0400
In-Reply-To: <20100531031953.GA10590@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wu Fengguang <fengguang.wu@intel.com>
Date: Mon, 31 May 2010 11:19:53 +0800

> Normally dhclient can be configured to send the "host-name" option
> in DHCP requests to update the client's DNS record. However for an
> NFSROOT system, dhclient shall never be called (which may change the
> IP addr and therefore lose your root NFS mount connection).
> 
> So enable updating the DNS record with kernel parameter
> 
> 	ip=::::$HOST_NAME::dhcp
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Applied, thanks.
