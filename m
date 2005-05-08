From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Sun, 08 May 2005 10:30:43 -0400
Message-ID: <1115562643.19561.148.camel@localhost.localdomain>
References: <20050505213239.GA29526@gondor.apana.org.au>
	 <1115331436.8006.112.camel@localhost.localdomain>
	 <20050505231210.GA30574@gondor.apana.org.au>
	 <1115342122.7660.25.camel@localhost.localdomain>
	 <20050506013125.GA31780@gondor.apana.org.au>
	 <1115345403.7660.49.camel@localhost.localdomain>
	 <20050506085404.GA26719@gondor.apana.org.au>
	 <1115380381.7660.123.camel@localhost.localdomain>
	 <20050507105500.GA20283@gondor.apana.org.au>
	 <1115469496.19561.41.camel@localhost.localdomain>
	 <20050508080730.GA30512@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050508080730.GA30512@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-08-05 at 18:07 +1000, Herbert Xu wrote:
> On Sat, May 07, 2005 at 08:38:16AM -0400, jamal wrote:
> > 
> > Rewrite it Herbert ;-> I have no qualms as long as the feature is
> > available. I even promised not to harass you ;->
> 
> Sorry, I can't think of any good ways to implement what you want.
> 

There is really nothing in my (small) patch that you have pointed out
that is unresolvable;->
You just dont like the idea, period.

> > > The difference is that the uniqueness is easy when we (the kernel) are
> > > the only ones setting it.  Once you let the user choose the value for
> > > index, that's where the horror starts.
> > 
> > But the uniqueness is still maintained. Nothing changes there.
> 
> The difference is that we now have to guarantee the uniqueness of
> two unrelated fields during insertion: the index as well as the
> selector.  This is where the complexity of your patch comes from.

Both the index and the selector MUST be unique, no question about that.
What i did is introduce setting of the index - and that makes the
checking do a little more. It would be worng not to do the checking.

> I'm afraid I don't buy this.  The policies are not stored in a
> linear random-access data structure.  So setting the index
> doesn't help performance one tiny bit.
> 
> In future it'll probably become a hash table or a tree, in neither
> case will there be a linear index that could be used to determine
> insertion/deletion.
> 

I am talking about user space apps - not the kernel.
Have you ever looked at IPSEC related MIBs and PIBs? or apps that
implement those sorts of entities? I suspect you have not otherwise we
would have closed this ages ago.

> Please elaborate by giving an example of how the index is actually
> used.  Sorry, but as it is I'm too thick to see your point :)
> 

I have given you enough info that i am concluding this is now becoming a
debate for the sake of one;->

Sorry, Herbert, I strongly disagree with your views on this topic. This
is one of those moments when it becomes obvious there can be no
compromise. So I am hoping that someone following this discussion or
writing management apps would speak up.

> > Having said the above, the SAD as well oughta have an index; infact one
> > exists (the reqid) but is quiet bizzare. I dont wanna touch the SAD,
> > yet ;-> not for the next few months until we talk at netconf probably.
> 
> The reqid is definitely not an index.  In fact it is not unique at all.
> It's a way of condensing all the fields in a SA template into one u32.
> 

I dont wanna talk about this right now; 

cheers,
jamal
