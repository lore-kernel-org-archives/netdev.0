From: "Teras Timo (EXT-YomiGroup/Helsinki)" <Ext-Timo.Teras@nokia.com>
Subject: Re: [PATCH] Add ability to register class interfaces for network class
Date: Wed, 27 Oct 2004 22:20:18 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027192018.GA12845@two.research.nokia.com>
References: <20041026183526.GA23535@two.research.nokia.com> <20041026184838.GB16621@infradead.org> <20041026205239.GA23825@two.research.nokia.com> <20041027111317.GA27240@infradead.org> <417F86F8.6020004@nokia.com> <20041027085906.665d0125@guest-251-240.pdx.osdl.net> <20041027183804.GA12585@two.research.nokia.com> <20041027115538.540de19e@guest-251-240.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ext ext Christoph Hellwig <hch@infradead.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ext Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041027115538.540de19e@guest-251-240.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 27, 2004 at 11:55:38AM -0700, ext Stephen Hemminger wrote:
> On Wed, 27 Oct 2004 21:38:04 +0300
> "Teras Timo (EXT-YomiGroup/Helsinki)" <Ext-Timo.Teras@nokia.com> wrote:
> > This way the problem is that I have to know which devices I will
> > add the attributes. But the point is to add attributes to
> > all netdevs.
> > 
> > Using this approach I'd have to enumerate all the interfaces every
> > now and then.
> > 
> > If I have my class interface I get a callback whenever an
> > interface is created or deleted and I can automatically add the
> > attribute to all netdevs.
> > 
> 
> If you are doing something to all interfaces, then it probably should
> either be part of the common net-sysfs layer, or you can dynamically
> discover and do it by following device transitions with 
> register_device_notifier.

I'd like my code to be available as module also so common net-sysfs
is not an option. Hmm... I could use device transitions hooks. 

But I'm still a bit puzzled why the interface registration should not
be public?

After all it is only a mechanism to get callbacks whenever a class
device is created or removed. Why to even implement a class interface
system if you are not allowed to use it (except in one special place
where it is considered to be an ugly hack by Christoph Hellwig)?

I understood that the whole point for interfaces is the ability to
extend functionality without core (i.e. common net-sysfs) changes.
Why to lose that modularity?

Cheers,
  Timo
