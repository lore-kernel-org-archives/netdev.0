From: Dmitry Yusupov <dmitry_yus@yahoo.com>
Subject: Re: [PATCH] NETLINK_UESTABLISHED notifier event
Date: Sat, 09 Apr 2005 09:02:59 -0700
Message-ID: <1113062579.3893.110.camel@beastie>
References: <E1DJ0YI-0003PR-00@gondolin.me.apana.org.au>
	 <42540CF3.7070501@cs.wisc.edu> <20050406212906.GA24775@gondor.apana.org.au>
	 <1112823442.16753.68.camel@beastie>
	 <20050406220417.GA4443@gondor.apana.org.au>
	 <1112826385.16753.99.camel@beastie>
	 <20050407213231.GA28738@gondor.apana.org.au>
	 <1112917001.3893.77.camel@beastie>
	 <20050408113654.GA26095@gondor.apana.org.au>
	 <1112974214.17165.8.camel@mylaptop>
	 <20050409014447.GA22607@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mike Christie <michaelc@cs.wisc.edu>, netdev@oss.sgi.com,
        davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050409014447.GA22607@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-09 at 11:44 +1000, Herbert Xu wrote:
> On Fri, Apr 08, 2005 at 08:30:14AM -0700, Dmitry Yusupov wrote:
> > 
> > This is ideally how it should be for sendmsg paths. socket applications
> > like iscsi, nbd, etc will use it for TCP/IP type of socket. iscsi could
> > re-use the same generic "emergency pool" code for netlink.
> 
> In that case we'll wait for the resolution of the discussion on TCP
> itself, OK?

"emergency pool" is a big and generic feature, needs design and
resolution. it could definitely wait. Do you have something against
one liner patch for using sk->sk_allocation instead of hard-coded vm
priority?
