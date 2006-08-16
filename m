From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 12:58:28 +1000
Message-ID: <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
References: <20060815122300.GV14627@postel.suug.ch>
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58628 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750856AbWHPC7L
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 22:59:11 -0400
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20060815122300.GV14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
>
> IPv4 address notifications originating from a netlink request now
> carry the netlink pid of the request instead of 0.

I'm not comfortable with that change since it implies the message
originated from a user-space process.

The netlink header pid is really akin to sadb_msg_pid from RFC 2367.
IMHO it should always be zero if the kernel is the originator of the
message.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
