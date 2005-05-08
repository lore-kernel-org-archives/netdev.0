From: Patrick McHardy <kaber@trash.net>
Subject: Re: resend patch:  xfrm policybyid
Date: Sun, 08 May 2005 17:23:57 +0200
Message-ID: <427E2F0D.4040902@trash.net>
References: <20050505213239.GA29526@gondor.apana.org.au>	 <1115331436.8006.112.camel@localhost.localdomain>	 <20050505231210.GA30574@gondor.apana.org.au>	 <1115342122.7660.25.camel@localhost.localdomain>	 <20050506013125.GA31780@gondor.apana.org.au>	 <1115345403.7660.49.camel@localhost.localdomain>	 <20050506085404.GA26719@gondor.apana.org.au>	 <1115380381.7660.123.camel@localhost.localdomain>	 <20050507105500.GA20283@gondor.apana.org.au>	 <1115469496.19561.41.camel@localhost.localdomain>	 <20050508080730.GA30512@gondor.apana.org.au> <1115562643.19561.148.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1115562643.19561.148.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Sun, 2005-08-05 at 18:07 +1000, Herbert Xu wrote:
> 
>>Please elaborate by giving an example of how the index is actually
>>used.  Sorry, but as it is I'm too thick to see your point :)
>
> I have given you enough info that i am concluding this is now becoming a
> debate for the sake of one;->
> 
> Sorry, Herbert, I strongly disagree with your views on this topic. This
> is one of those moments when it becomes obvious there can be no
> compromise. So I am hoping that someone following this discussion or
> writing management apps would speak up.

Allowing the user to freely set indices breaks racoon:

#ifdef __linux__
        /* bsd skips over per-socket policies because there will be no
         * src and dst extensions in spddump messages. On Linux the only
         * way to achieve the same is check for policy id.
         */
        if (xpl->sadb_x_policy_id % 8 >= 3) return 0;
#endif

So how could we handle this?

Regards
Patrick
