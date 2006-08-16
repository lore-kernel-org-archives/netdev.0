From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 12:58:56 +0200
Message-ID: <20060816105856.GW14627@postel.suug.ch>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:34192 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750857AbWHPK6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 06:58:36 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Herbert Xu <herbert@gondor.apana.org.au> 2006-08-16 12:58
> I'm not comfortable with that change since it implies the message
> originated from a user-space process.
> 
> The netlink header pid is really akin to sadb_msg_pid from RFC 2367.
> IMHO it should always be zero if the kernel is the originator of the
> message.

All route and tc notifications already use the pid so applications
can decide whether the event was caused by them. A notification
is a reply to a request so it doesn't even violate RFC 2367.
