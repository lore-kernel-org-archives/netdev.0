From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in prefix length
Date: Sat, 5 Mar 2005 12:03:19 +1100
Message-ID: <20050305010319.GB27804@gondor.apana.org.au>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch> <42290172.7020403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <42290172.7020403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 05, 2005 at 01:46:42AM +0100, Patrick McHardy wrote:
> 
> I think that would be ok. Unrelated to this: for IFA_ADDRESS we don't
> do an exact match, perhaps we should also do this for IFA_LOCAL for
> consistency.

You mean that we do do an exact match for IFA_ADDRESS? Yes that's
exactly what Thomas is trying to fix for IFA_LOCAL.  The only problem
is that people may have come to depend on the "wildcard" match behaviour
of IFA_LOCAL, i.e.:

ip a a dev eth0 192.168.0.1/24
ip a d dev eth0 192.168.0.1

His proposal of encoding a wildcard bit in IFA_LOCAL's prefix length
should solve the problem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
