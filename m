From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 01:31:49 +0100
Message-ID: <20050305003149.GK31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050305002910.GJ31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I've been thinking about this since yesterday and the best solution I
> came up so far is to encode it in one of the yet unused bits in
> the prefixlength field. After all we're only using 5bits of it. What
> i'm thinking of in particular is to encode it as in 1 bit wildcard
> flag 5 bits prefix length.

6 bits i meant of course, silly me. ;->
