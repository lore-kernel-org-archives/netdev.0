From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: Mon, 30 Aug 2004 21:29:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830212910.78047bcd.davem@davemloft.net>
References: <1093799632.1073.410.camel@jzny.localdomain>
	<20040830144033.2265a6e6.davem@redhat.com>
	<1093904088.1043.12.camel@jzny.localdomain>
	<20040830154430.769d1d59.davem@redhat.com>
	<1093906592.1037.32.camel@jzny.localdomain>
	<20040830160052.548c4846.davem@redhat.com>
	<1093916592.1037.51.camel@jzny.localdomain>
	<20040830191716.0d002f91.davem@redhat.com>
	<1093919823.1043.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093919823.1043.80.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 30 Aug 2004 22:37:03 -0400
jamal <hadi@cyberus.ca> wrote:

> thmart. Lets go with this then. Steve, do you wanna take it from here
> with the iproute2 patch i sent or you want me to generate a new one? Now
> how do we tell all other people who have written netlink apps
> to beware?

Yeah, how are you going to "tell those other people"?  And how
are you going to get every user to know to upgrade all of those
apps when they try to use a kernel with your patch applied?

Look, let's get real about this topic.  We can't be breaking shit
like this all the time.  We're nearly letting it happen a lot
lately.

These data structures are user visible APIs, they are just like
system call data structures, and if we cannot modify
them without potentially breaking some existing application we
cannot make that change.

So please find another way to add make this statistic visible to
userspace Jamal.  Thanks a lot.
