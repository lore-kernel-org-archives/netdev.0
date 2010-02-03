From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Wed, 03 Feb 2010 15:04:29 -0500
Message-ID: <1265227469.2861.311.camel@tonnant>
References: <4B685756.8010107@trash.net> <1265130426.2861.158.camel@tonnant>
	 <b6fcc0a1002020958u17315624u4d54d06a413be6bb@mail.gmail.com>
	 <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>
	 <4B6967BC.600@trash.net> <1265222289.2861.290.camel@tonnant>
	 <20100203190948.GA5182@x200> <1265226227.2861.302.camel@tonnant>
	 <1265226371.2861.303.camel@tonnant>  <20100203195338.GB5576@x200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100203195338.GB5576@x200>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-02-03 at 21:53 +0200, Alexey Dobriyan wrote:
> On Wed, Feb 03, 2010 at 02:46:11PM -0500, Jon Masters wrote:
> > On Wed, 2010-02-03 at 14:44 -0500, Jon Masters wrote:
> > > On Wed, 2010-02-03 at 21:09 +0200, Alexey Dobriyan wrote:
> > > > On Wed, Feb 03, 2010 at 01:38:09PM -0500, Jon Masters wrote:
> > 
> > > > > I also think it is necessary to expose net namespace layout
> > > > 
> > > > Not necessary. Why?
> > > 
> > > How am I as a sysadmin supposed to figure out which net namespaces exist
> > > on my system, and as a developer, supposed to debug these situations?
> > 
> > (without Jason's excellent kgdb patches, which really help)
> 
> Oh! Just like as usual, thinking and looking at oops and code.
> 
> Because when box is dead, netns info is not goint to be printed
> anyway.

It would really have been helpful over the weekend to have just been
able to look around in sysfs to see what was going on with namespaces.
I'm not saying it can't be done in a debugger, or by poking at
backtraces, but it's easier to say to the many people who had this
problem in Fedora kernels "tell me what this file says" just like we do
for slab, memory, whatever other information. Just a suggestion.

> And what do you want to see at it?

Just an ability to walk through which namespaces exist (debugfs even)
and which resources are currently assigned to them. Somehow. I didn't
give it a lot of thought, but something would be useful.

Jon.


