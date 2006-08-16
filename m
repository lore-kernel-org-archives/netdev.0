From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to
	use rtnl_notify()
Date: Wed, 16 Aug 2006 07:03:18 -0400
Message-ID: <1155726198.5122.54.camel@jzny2>
References: <20060815122300.GV14627@postel.suug.ch>
	 <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
	 <20060816105856.GW14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, hasso@estpak.ee,
	kuznet@ms2.inr.ac.ru, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:9369 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S1750892AbWHPLDc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 07:03:32 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1GDJBO-0001oX-M0
	for netdev@vger.kernel.org; Wed, 16 Aug 2006 07:03:34 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060816105856.GW14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-16-08 at 12:58 +0200, Thomas Graf wrote:
> * Herbert Xu <herbert@gondor.apana.org.au> 2006-08-16 12:58
> > I'm not comfortable with that change since it implies the message
> > originated from a user-space process.
> > 
> > The netlink header pid is really akin to sadb_msg_pid from RFC 2367.
> > IMHO it should always be zero if the kernel is the originator of the
> > message.
> 
> All route and tc notifications already use the pid so applications
> can decide whether the event was caused by them. A notification
> is a reply to a request so it doesn't even violate RFC 2367.

I would agree with Thomas on this. Regardless, I dont think that 2367 is
really a glorified reference (that thing needs so much updating it is
not funny).

cheers,
jamal



