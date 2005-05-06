From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Thu, 05 May 2005 21:15:22 -0400
Message-ID: <1115342122.7660.25.camel@localhost.localdomain>
References: <1115298877.7680.75.camel@localhost.localdomain>
	 <20050505213239.GA29526@gondor.apana.org.au>
	 <1115331436.8006.112.camel@localhost.localdomain>
	 <20050505231210.GA30574@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050505231210.GA30574@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 09:12 +1000, Herbert Xu wrote:
> On Thu, May 05, 2005 at 06:17:15PM -0400, jamal wrote:
> >
> > > This is still racy since delp can be killed by timers before you get
> > > the lock.
> > 
> > Ok, Herbert - this is fixable: I take it moving the lock one up is
> > sufficient; i dont mind if you fix it and add it to your list.
> 
> I know it's fixable, but the problem is that the fix is likely to
> make this function even uglier :)
> 

I am giving you the opportunity now to fix it your way;->  
Rewrite if you want. I promise not to hassle you ;->

> What I still don't get is who would be using this feature.  
> No I
> don't mean an example of how the ip command can do this :) 

Oh, wait, ip doesnt count as an app?;-> Now, lets say it doesnt.
The incosistency i see is not something i have seen in any table logic
in the kernel or anywhere else.
a) I am allowed to set the id to say a 1 only to be  overruled by the
kernel which sets it to 8? 
b) The table is searchable by id - except i just cant set the search
key.

So for the sake of correctness, at least, this needs to be fixed.

> I mean
> a real-world scenario why someone or some KM would want do this and
> why it can't be done easily with what we've already got.
> 

Thats a moot point really Herbert. I can think of a few apps that can
use this, but it shouldnt matter: The main point is correctness.

You know what else you can do is get rid of the index totaly - that
would be fine with me. What do you say to that?


cheers,
jamal
