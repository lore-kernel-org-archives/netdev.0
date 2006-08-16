From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH 09/16] [IPv6] address: Convert address notification to use rtnl_notify()
Date: Wed, 16 Aug 2006 17:04:37 +0400
Message-ID: <20060816130437.GC16917@ms2.inr.ac.ru>
References: <20060815122300.GV14627@postel.suug.ch> <E1GDBbw-0006Kz-00@gondolin.me.apana.org.au> <20060816105856.GW14627@postel.suug.ch> <20060816111240.GA28846@gondor.apana.org.au> <20060816113950.GA29003@gondor.apana.org.au> <1155729864.5122.95.camel@jzny2> <20060816120808.GA14627@postel.suug.ch> <1155731791.5122.115.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>, hasso@estpak.ee,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:43156 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751030AbWHPNFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 09:05:05 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1155731791.5122.115.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> In one conversation with Alexey he told me there was some inspiration
> from pfkey in the semantics of it i.e processid.

Inspiration, but not a copy. :-)

Unlike pfkeyv2 it uses addressing usual for networking i.e.
struct sockaddr_nl.

Alexey
