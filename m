From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Sat, 9 Apr 2005 11:44:47 +1000
Message-ID: <20050409014447.GA22607@gondor.apana.org.au>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au> <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au> <1112823442.16753.68.camel@beastie> <20050406220417.GA4443@gondor.apana.org.au> <1112826385.16753.99.camel@beastie> <20050407213231.GA28738@gondor.apana.org.au> <1112917001.3893.77.camel@beastie> <20050408113654.GA26095@gondor.apana.org.au> <1112974214.17165.8.camel@mylaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Dmitry Yusupov <dmitry_yus@yahoo.com>
Content-Disposition: inline
In-Reply-To: <1112974214.17165.8.camel@mylaptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 08, 2005 at 08:30:14AM -0700, Dmitry Yusupov wrote:
> 
> This is ideally how it should be for sendmsg paths. socket applications
> like iscsi, nbd, etc will use it for TCP/IP type of socket. iscsi could
> re-use the same generic "emergency pool" code for netlink.

In that case we'll wait for the resolution of the discussion on TCP
itself, OK?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
