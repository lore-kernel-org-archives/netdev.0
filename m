From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 1/1]: bna: Fix build break for allyesconfig
Date: Wed, 25 Aug 2010 16:25:35 -0700 (PDT)
Message-ID: <20100825.162535.102560853.davem@davemloft.net>
References: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
	<20100825.152243.260093985.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86A4AE226112@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amathur@brocade.com, ddutt@Brocade.COM,
	huangj@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53109
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751772Ab0HYXZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:25:20 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A4AE226112@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Wed, 25 Aug 2010 16:05:43 -0700

> We are working on fixing it properly. We will submit the patches as
> soon as possible.

Thank you.

Also, if this is essentially two copies of the same piece of code,
consider splitting it out into a seperate module in the future.  There
are a few drivers which do this, f.e. see the MLX4 driver, which
supports both a network device and an infiniband device out of the
same hardware, using a core of shared code in a seperate module called
mlx4_core which exports symbols to the network and infiniband drivers.

