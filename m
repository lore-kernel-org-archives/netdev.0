From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: 21 Sep 2004 08:22:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095769363.1048.110.camel@jzny.localdomain>
References: <20040918203319.24004d6e.davem@davemloft.net>
	 <1095645106.1048.190.camel@jzny.localdomain>
	 <20040919195351.0b3560e6.davem@davemloft.net>
	 <1095686672.1049.301.camel@jzny.localdomain>
	 <20040920121123.70baf895.davem@davemloft.net>
	 <20040921034212.GA28462@gondor.apana.org.au>
	 <20040920231805.3f18479c.davem@davemloft.net>
	 <20040921090423.GE8058@wotan.suse.de>
	 <20040921093252.GA32545@gondor.apana.org.au>
	 <1095764621.1049.14.camel@jzny.localdomain>
	 <20040921120753.GA20236@wotan.suse.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040921120753.GA20236@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-21 at 08:07, Andi Kleen wrote:

> I didn't know you were addicted to glossyware, jamal ;-)

Not me, but i have the unfortunate luck (is there such a thing?)
to deal with foolish people everyday ;->
Theres a lot of glossyware out there that claims they are more
1812 compliant than Linux. They specifically mention Linux.
Think of a midlevel manager (who just read network magazine) and now
armed with a check list;-> 
I know a "marketing" arguement is a weak one - but having been
victimized i thought id share it. 

> You could still do routing by TOS, all you would need to do is to 
> set up a netfilter rule that checks the TOS and set an fwmark, then
> route based on that.
> 
> The only thing you lose is ICMP redirect routes per TOS.
> I'm not sure it is worth keeping. And making the FIB scale
> better would likely look far better in the glossyware than
> that. 

I think FIB scalaing is first priority. In the past you could
selectively turn off TOS checking at compile. Why cant we do it that
way?


cheers,
jamal
