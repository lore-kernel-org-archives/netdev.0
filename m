From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET::SCHED]: cleanup qdisc_restart
Date: Mon, 14 Aug 2006 18:57:27 -0400
Message-ID: <1155596247.6946.9.camel@jzny2>
References: <1155408186.5091.46.camel@jzny2> <44E1DD5F.4020603@osdl.org>
	 <20060814.140136.88477982.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:14212 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S965023AbWHNW5d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 18:57:33 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GClNK-0007c0-4o
	for netdev@vger.kernel.org; Mon, 14 Aug 2006 18:57:38 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060814.140136.88477982.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-14-08 at 14:01 -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 15 Aug 2006 07:42:39 -0700
> 
> > Please don't change the values because some older drvers still return 1 
> > rather
> > than NETDEV_TX_BUSY
> 
> Unfortunately, this is probably very true.  So we indeed cannot
> change the NETDEV_TX_BUSY value.

That slipped from the experiments i was trying out. I can use valid
return codes.
The question to ask though is: shouldnt we be having drivers use the
mnemonics instead of values like 1? 

cheers,
jamal

