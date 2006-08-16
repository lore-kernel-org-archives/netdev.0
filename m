From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 13:04:04 +1000
Message-ID: <20060816030404.GA24441@gondor.apana.org.au>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hasso@estpak.ee, kuznet@ms2.inr.ac.ru, hadi@cyberus.ca,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1797 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750862AbWHPDET
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 23:04:19 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 12:58:28PM +1000, Herbert Xu wrote:
> 
> I'm not comfortable with that change since it implies the message
> originated from a user-space process.
> 
> The netlink header pid is really akin to sadb_msg_pid from RFC 2367.
> IMHO it should always be zero if the kernel is the originator of the
> message.

Actually I think this has the potential to break applications that
ignore any messages with the original pid set to a non-zero value.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
