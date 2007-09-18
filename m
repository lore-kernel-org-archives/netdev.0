From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.22.6 NETWORKING [IPV4]: Always use source addr in
 skb to reply packet
Date: Mon, 17 Sep 2007 19:20:44 -0700 (PDT)
Message-ID: <20070917.192044.48396034.davem@davemloft.net>
References: <20070918021617.GA15540@router.lepton.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ytht.net@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38461
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754299AbXIRCUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:20:46 -0400
In-Reply-To: <20070918021617.GA15540@router.lepton.home>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: lepton <ytht.net@gmail.com>
Date: Tue, 18 Sep 2007 10:16:17 +0800

> Hi,
>   In some situation, icmp_reply and ip_send_reply will send
>   out packet with the wrong source addr, the following patch
>   will fix this.
> 
>   I don't understand why we must use rt->rt_src in the current
>   code, if this is a wrong fix, please correct me.
> 
> Signed-off-by: Lepton Wu <ytht.net@gmail.com>

That the address is wrong is your opinion only :-)

Source address selection is a rather complex topic, and
here we are definitely purposefully using the source
address selected by the routing lookup for the reply.
