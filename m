From: Jason Lunz <lunz@falooley.org>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 19:23:51 -0500
Message-ID: <20050310002351.GE16930@knob.localnet>
References: <20050309235122.7541.qmail@orange.bonev.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Boian Bonev <boian@bonev.com>
Content-Disposition: inline
In-Reply-To: <20050309235122.7541.qmail@orange.bonev.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2005 at  1:51AM +0200, Boian Bonev wrote:
> you can do that but you omit the interface addresses - suppose ext net
> is 10.20.10.1/24, internal is 10.10.10.1/24, no matter what routing
> policies and rules you put, both interface ips will be visible from
> both interfaces.

What do you mean by "visible"? If you're referring to arp, the arp
sysctls are probably adequate, and there's arpfilter if not.

> now imagine you have another external net 10.30.10.1/24 and customer
> wants to route e.g. 10.10.0.0/16 from 10.20.10.1/24 via 10.30.10.5...
> at least host 10.10.10.1 will not route but arrive locally to your
> blade host

Not if you take 10.10.10.1 out of the "local" routing table, and policy
route that traffic only through tables that don't consider 10.10.10.1
local. I'm not saying it's trivial, but if you set your rules up right,
you can make some packets be routed by *completely different routing
tables* than others.

Jason
