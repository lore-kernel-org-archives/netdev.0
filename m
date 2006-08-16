From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Wed, 16 Aug 2006 09:11:10 -0400
Message-ID: <1155733870.5122.137.camel@jzny2>
References: <20060815122300.GV14627@postel.suug.ch>
	 <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
	 <20060816105856.GW14627@postel.suug.ch>
	 <20060816111240.GA28846@gondor.apana.org.au>
	 <20060816113950.GA29003@gondor.apana.org.au>
	 <1155729864.5122.95.camel@jzny2> <20060816120808.GA14627@postel.suug.ch>
	 <1155731791.5122.115.camel@jzny2>  <20060816130437.GC16917@ms2.inr.ac.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>, hasso@estpak.ee,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19947 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1751172AbWHPNLN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 09:11:13 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GDLAy-0005mq-9T
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 09:11:16 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060816130437.GC16917@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-16-08 at 17:04 +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> > In one conversation with Alexey he told me there was some inspiration
> > from pfkey in the semantics of it i.e processid.
> 
> Inspiration, but not a copy. :-)

Oh, absolutely. Netlink is way superior. I should have said perspiration
instead of inspiration;-> Calling inspiration was being polite - it is
as being polite as saying i was being economical with the truth[1] ;->

> Unlike pfkeyv2 it uses addressing usual for networking i.e.
> struct sockaddr_nl.

I think this needs to be captured somewhere. I dont know who is
maintaining the man pages these days.

cheers,
jamal

[1] A term i learnt from some British guy. They have ways with words
those Brits.

