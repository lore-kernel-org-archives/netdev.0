From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: IPSEC xfrm events
Date: 01 Apr 2005 07:59:39 -0500
Message-ID: <1112360379.1096.193.camel@jzny.localdomain>
References: <1112319441.1089.83.camel@jzny.localdomain>
	 <20050401042106.GA27762@gondor.apana.org.au>
	 <1112353398.1096.116.camel@jzny.localdomain>
	 <20050401114258.GA2932@gondor.apana.org.au>
	 <1112358278.1096.160.camel@jzny.localdomain>
	 <20050401123554.GA3468@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050401123554.GA3468@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-04-01 at 07:35, Herbert Xu wrote:
> On Fri, Apr 01, 2005 at 07:24:38AM -0500, jamal wrote:
> > 
> > I think either scheme is fine really;-> I will definetely go back and
> > consider the approach you are suggesting and see if it results into
> > more maintanable code - then fair. Otherwise you realize its more work
> > for me ;->
> 
> Well I'm happy to code that part if you want :)
>  

Let me review first. If it is valuable (we may have to leave expire
alone). If i can get it done within next day or two fine - else if i get
busyed out elsewhere i will hand it to you. Actually if you have plenty
cycles and are very enthusiastic about this i can hand it to you right
now ;-> Masahide and myself have some momentum going right now but i
dont think this will be that disruptive.

> You're right that the RFC isn't very clear.
> 
> Let's forget about the RFC and simply consider the usefulness of this.
> I contend that it is useful to see a FLUSH notification even when
> it flushed nothing.
> 
> The reason is that this is an indication to all listeners that the
> database is completely empty.
> 

Ok, let me hear from Masahide-san: If he still holds the same opinion as
you then i will make the change.


> > Thats a bug really which is being exposed now. So it has nothing to do
> > with the approach taken ;-> 
> 
> You're right that it is a bug.  However, this bug would've never triggered
> before because we simply didn't have delete policy notifications :)
> 

indeed.

> > No expire should be sent if the policy has transitioned to dead. The bug
> > is trivial to fix - and actually should be fixed regardless of this
> > patch.
> 
> Yes the same fix to __xfrm_state_delete can be applied to
> xfrm_policy_delete.
> 

agreed.

cheers,
jamal
