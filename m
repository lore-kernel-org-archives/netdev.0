From: Song Wang <wsonguci@yahoo.com>
Subject: Re: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: Wed, 22 Sep 2004 17:29:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923002906.60244.qmail@web40007.mail.yahoo.com>
References: <1095334258.1065.158.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1095334258.1065.158.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > 
> > Although I would very much anticipate this being
> > a MIPS or network adapter specific problem since
> > on x86 routing is pretty fast in 2.6.x
> 
> Note, I could hit 4-500Kpps on a bcom sb1250 800Mhz;
> trying to simulate
> Andis gettimeofday changes (which are in 2.6 since i
> havent seen a 2.6
> port for that board ) gives another 100Kpps. Theres
> still room for
> improvement just havent had time.
> You are right though it could be a 2.6.x arch
> specific issue. Bacchus?
> 
> cheers,
> jamal
> 
> 
Hi Jamal and Dave,

I continued to do some testing in a minimal
environment, basically the routing between the
two ethernet ports on the mips board. Only
ethernet driver is loaded. The user-space
only has busybox.

The difference between 2.6.8.1 and 2.4.17 kernel
is 3000pps less for routing. However, the bridging
performance is the same between two kernels.

Jamal, where is the Andis gettimeofday changes
you mentioned?

Thanks.

-Song





		
__________________________________
Do you Yahoo!?
Yahoo! Mail is new and improved - Check it out!
http://promotions.yahoo.com/new_mail
