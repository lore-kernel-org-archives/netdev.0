From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] 2.6.22.6 NETWORKING [IPV4]: Always use source addr in
 skb to reply packet
Date: Tue, 18 Sep 2007 11:26:44 +0900 (JST)
Message-ID: <20070918.112644.28694997.yoshfuji@linux-ipv6.org>
References: <20070918021617.GA15540@router.lepton.home>
	<20070917.192044.48396034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, yoshfuji@linux-ipv6.org
To: ytht.net@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44083 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbXIRCZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:25:13 -0400
In-Reply-To: <20070917.192044.48396034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070917.192044.48396034.davem@davemloft.net> (at Mon, 17 Sep 2007 19:20:44 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> From: lepton <ytht.net@gmail.com>
> Date: Tue, 18 Sep 2007 10:16:17 +0800
> 
> > Hi,
> >   In some situation, icmp_reply and ip_send_reply will send
> >   out packet with the wrong source addr, the following patch
> >   will fix this.
> > 
> >   I don't understand why we must use rt->rt_src in the current
> >   code, if this is a wrong fix, please correct me.
> > 
> > Signed-off-by: Lepton Wu <ytht.net@gmail.com>
> 
> That the address is wrong is your opinion only :-)
> 
> Source address selection is a rather complex topic, and
> here we are definitely purposefully using the source
> address selected by the routing lookup for the reply.

And, if you do think something is "wrong", you need to describe it
in detail, at least.

--yoshfuji
