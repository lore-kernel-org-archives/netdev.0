From: jamal <hadi@cyberus.ca>
Subject: Re: take 2  WAS(Re: PATCH: IPSEC xfrm events
Date: 03 Apr 2005 22:34:04 -0400
Message-ID: <1112582044.1087.421.camel@jzny.localdomain>
References: <1112353398.1096.116.camel@jzny.localdomain>
	 <20050401114258.GA2932@gondor.apana.org.au>
	 <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
	 <1112403845.1088.14.camel@jzny.localdomain>
	 <20050402012813.GA24575@gondor.apana.org.au>
	 <1112406164.1088.54.camel@jzny.localdomain>
	 <20050402014619.GB24861@gondor.apana.org.au>
	 <1112469601.1088.173.camel@jzny.localdomain>
	 <1112538718.1096.394.camel@jzny.localdomain>
	 <20050404005805.GA16543@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050404005805.GA16543@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-04-03 at 20:58, Herbert Xu wrote:
> ;
> > +	// XXX:do we have to pass proto as well?
> 
> I think so.  A flush of all IPCOMP states is certainly quite different
> from a flush of all states.  It's just a matter of calling satype2proto.

I think you meant pfkey_proto2satype(). i.e 
hdr->sadb_msg_satype = pfkey_proto2satype(c->data);

BTW, slightly different from the way netlink does bussiness.

cheers,
jamal
