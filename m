From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Fri, 4 Mar 2005 14:30:42 +0100
Message-ID: <20050304133042.GG31837@postel.suug.ch>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1D78DN-0002te-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1D78DN-0002te-00@gondolin.me.apana.org.au> 2005-03-04 19:31
> Do we really need to handle this case? If we do then would it be better
> to consider ifa_prefixlen only when there are multiple addresses present
> which match but differ by prefix length?

One argument that would speak for the original patch is that IPv6
already handles it this way so it would be more consistent.
