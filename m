From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 31 Aug 2004 14:09:13 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093975753.1052.14.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <20040830144033.2265a6e6.davem@redhat.com>
	 <1093904088.1043.12.camel@jzny.localdomain>
	 <20040830154430.769d1d59.davem@redhat.com>
	 <1093906592.1037.32.camel@jzny.localdomain>
	 <20040830160052.548c4846.davem@redhat.com>
	 <1093916592.1037.51.camel@jzny.localdomain>
	 <20040830191716.0d002f91.davem@redhat.com>
	 <1093919823.1043.80.camel@jzny.localdomain>
	 <20040830212910.78047bcd.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040830212910.78047bcd.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-08-31 at 00:29, David S. Miller wrote:
> On 30 Aug 2004 22:37:03 -0400
> jamal <hadi@cyberus.ca> wrote:
> 
> > thmart. Lets go with this then. Steve, do you wanna take it from here
> > with the iproute2 patch i sent or you want me to generate a new one? Now
> > how do we tell all other people who have written netlink apps
> > to beware?
> 
> Yeah, how are you going to "tell those other people"?  And how
> are you going to get every user to know to upgrade all of those
> apps when they try to use a kernel with your patch applied?


Again, thats not an issue. new kernel. old app should work
Challenge is old kernel, new app.

> Look, let's get real about this topic.  We can't be breaking shit
> like this all the time.  We're nearly letting it happen a lot
> lately.

Agreed.

> These data structures are user visible APIs, they are just like
> system call data structures, and if we cannot modify
> them without potentially breaking some existing application we
> cannot make that change.
> 
> So please find another way to add make this statistic visible to
> userspace Jamal.  Thanks a lot.

Well, Franks A Lot(TM) Dave ;->
Let me rethink - I will be back.

cheers,
jamal
