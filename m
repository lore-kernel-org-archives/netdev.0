From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 22 Jun 2005 15:23:25 -0700 (PDT)
Message-ID: <20050622.152325.15263910.davem@davemloft.net>
References: <20050622180654.GX14251@wotan.suse.de>
	<20050622.132241.21929037.davem@davemloft.net>
	<42B9DA4D.5090103@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, leonid.grossman@neterion.com, hadi@cyberus.ca,
        becker@scyld.com, rick.jones2@hp.com, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dada1@cosmosbay.com
In-Reply-To: <42B9DA4D.5090103@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 22 Jun 2005 23:38:21 +0200

> Then maybe we could also play with prefetchw() in the case the
> incoming frame is small enough to be copied to a new skb.

That's a good idea too.  In fact, this would deal with platforms
that use non-temporal stores in their memcpy() implementation.
