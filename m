From: Carl-Johan Bostorp <ctor@krixor.xy.org>
Subject: Re: packet socket can't steal packets
Date: Wed, 3 Jan 1990 21:25:00 +0100
Sender: owner-netdev@oss.sgi.com
Message-ID: <19900103212500.A4614@ratula.chimaira.se>
References: <Pine.OSF.4.30.0205072042410.30796-100000@kosh.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <Pine.OSF.4.30.0205072042410.30796-100000@kosh.hut.fi>; from dima@cc.hut.fi on Tue, May 07, 2002 at 09:02:31PM +0300
List-Id: netdev.vger.kernel.org

On Tue, May 07, 2002 at 09:02:31PM +0300, Dmitrii Tisnek wrote:
> hey, I've been trying to change certain network packet mangling software
> such that it would not need a kernel module, and it seems to me that,
> unfortunately there's no way to make packet socket "steal" packets it
> deliveres to the user mode.

"Divert Sockets for Linux" springs to my mind.. 

http://www.anr.mcnc.org/~divert/index.shtml

---
   Divert sockets enable both IP packet interception and injection on the
   end-hosts as well as on routers. Interception and injection happen at
   the IP layer. The intercepted packets are diverted to sockets in the
   user space, thus they will not be able to reach their destination
   unless they are reinjected by the user space sockets. This allows
   different tricks (e.g., routing and firewall) to be played, outside
   the operating system kernel, in between the packet interception and
   reinjection.
---


-- 
~~~<*>~~~

Web: http://elemental.webservices.se/		   ICQ: 3534707
PGP: 0xA6B5C43B					IRCnet: ctor

~~~<*>~~~
