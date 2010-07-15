From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] xfrm: cleanup of xfrm_input.c.
Date: Wed, 14 Jul 2010 17:59:55 -0700 (PDT)
Message-ID: <20100714.175955.183049583.davem@davemloft.net>
References: <AANLkTik6qHgbCVwZfMGXpso4p2DTC9w6U9agdFVl1ZbN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60095
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753419Ab0GOA7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 20:59:39 -0400
In-Reply-To: <AANLkTik6qHgbCVwZfMGXpso4p2DTC9w6U9agdFVl1ZbN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Wed, 14 Jul 2010 11:18:41 +0300

> Hi,
>  The patch removes unneeded inclusion of header files
> (linux/module.h, linux/netdevice.h, net/dst.h and net/ip.h)
>  in net/xfrm/xfrm_input.c
> 
> Regards,
> Rami Rosen
> 
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

If you do this, I also want to see you add includes for things like
linux/skbuff.h since data structures such as "struct sk_buff"
are used in this file.

Otherwise, this is how we end up with obscure build failures on
some configurations and not others, either now or in the future
when a similar change is made to some header file.

