From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 21:40:36 +0300
Message-ID: <20050129184036.GB29233@yakov.inr.ac.ru>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au> <20050128234828.GA24868@yakov.inr.ac.ru> <20050129002128.GX31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050129002128.GX31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> alignment though. Can someone enlighten me about the magic 31 in there?

It was me who wrote both NLMSG_GOODSIZE and this crap. Does the explanation
sound enough? :-)

Apparently it was a brainless attempt of formal merge of (broken)
NLMSG_GOODSIZE and inversed calculation in alloc_skb. Delete this 31.

Alexey
