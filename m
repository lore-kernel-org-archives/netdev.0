From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] gianfar: Fix potential oops during OF address
 translation
Date: Fri, 23 Apr 2010 16:20:48 -0700 (PDT)
Message-ID: <20100423.162048.188424167.davem@davemloft.net>
References: <20100423171244.GB2140@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sandeep.Kumar@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751494Ab0DWXUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 19:20:43 -0400
In-Reply-To: <20100423171244.GB2140@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Fri, 23 Apr 2010 21:12:44 +0400

> gianfar driver may pass NULL pointer to the of_translate_address(),
> which may lead to a kernel oops. Fix this by using of_iomap(), which
> is also much simpler and shorter.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>

Also applied to net-2.6, thanks.
