From: jamal <hadi@cyberus.ca>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: 10 Apr 2005 10:10:44 -0400
Message-ID: <1113142244.1088.287.camel@jzny.localdomain>
References: <1112702604.1089.119.camel@jzny.localdomain>
	 <20050409105452.GA7171@gondor.apana.org.au>
	 <20050409111244.GB7171@gondor.apana.org.au>
	 <1113049844.1090.23.camel@jzny.localdomain>
	 <20050409192926.GA9423@gondor.apana.org.au>
	 <20050409200306.GA9660@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050409200306.GA9660@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-09 at 16:03, Herbert Xu wrote:

> xfrm_policy_kill can only be called by the one who removed the
> policy from the linked list.  Therefore it can never fail.
> 
> If this logic is wrong we will be getting fat warnings from
> xfrm_policy_kill.
> 

The warning will kick in but it may be as rare as the issue of a delete
and expire happening on the same policy that your patch was supposed to
stop ;->

cheers,
jamal
