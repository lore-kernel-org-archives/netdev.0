From: Jamal Hadi <hadi@shell.cyberus.ca>
Subject: Re: Route cache performance under stress
Date: Mon, 9 Jun 2003 08:18:50 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609080430.I34540@shell.cyberus.ca>
References: <000401c32e5e$a707b6d0$4a00000a@badass> <20030609072227.R34462@shell.cyberus.ca>
 <20030609.045547.91327851.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030609.045547.91327851.davem@redhat.com>
List-Id: netdev.vger.kernel.org



On Mon, 9 Jun 2003, David S. Miller wrote:

>    From: Jamal Hadi <hadi@shell.cyberus.ca>
>    Date: Mon, 9 Jun 2003 07:38:44 -0400 (EDT)
>
>    Yes, you have a nice setup and thats why you should test all the patches
>    DaveM is posting. Dave, Paul is running in a real ISP environment i think
>    he is very valuable in helping to test these patches and collect
>    any says that might be needed. Now watch him disapear ;->
>
> If he doesn't test my patches he isn't very useful,
> so we'll see :-)

Ok foo the pressure in on you now ;->
You wanna see things fixed then run the damn tests or stop bitching ;->

> You're going to prefetch "nextrth" when the first thing we're
> going to access is "&nextrth->fl"? :-)
>
> It only makes sense to prefetch the 'fl' member of the first hash
> chain entry and that's what I've done in my tree.  This points out
> that it would make sense to put the struct flowi up into the dst
> entry.

yes moving the flowi up makes more sense. I found in my tests with a
ethernet driver that prefetching the _next_ dma descriptor gave better
numbers than prefetching the current one but i didnt spend too much time.
I am going to revisit this. Good thought on rearranging the structure,
may help with the descriptors as well.

cheers,
jamal
