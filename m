From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 NET] Fix ifmap alignment issues over rtnetlink
Date: Tue, 21 Sep 2004 19:36:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921193620.705e033c.davem@davemloft.net>
References: <20040921224127.GM566@postel.suug.ch>
	<E1C9wiC-0003gJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C9wiC-0003gJ-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 12:18:28 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> > +               err = dev->set_config(dev, (struct ifmap *) &k_map);
> 
> What's this cast for?

Good catch, I deleted the cast when I applied his
patch.

Thanks Herbert.
