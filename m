From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
 __xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Sun, 09 Aug 2009 21:52:01 -0700 (PDT)
Message-ID: <20090809.215201.139937635.davem@davemloft.net>
References: <alpine.DEB.1.10.0908061147060.3426@sisapiiri.net.net>
	<20090806.104034.186857842.davem@davemloft.net>
	<alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joamaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49999
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751569AbZHJEvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:51:51 -0400
In-Reply-To: <alpine.DEB.1.10.0908071032171.3426@sisapiiri.net.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Maki <joamaki@gmail.com>
Date: Fri, 7 Aug 2009 10:38:14 +0300 (EEST)

> 
> This patch fixes hash collisions in cases where number
> of entries have incrementing IP source and destination addresses
> from single respective subnets (i.e. 192.168.0.1-172.16.0.1, 
> 192.168.0.2-172.16.0.2, and so on.).
> 
> Signed-off-by: Jussi Maki <joamaki@gmail.com>

Applied.
