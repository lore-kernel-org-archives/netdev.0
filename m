From: Donald Becker <becker@scyld.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 3 Jan 2003 20:39:50 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301032029540.29812-100000@beohost.scyld.com>
References: <3E163648.2040204@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3E163648.2040204@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Jan 2003, Jeff Garzik wrote:
> jamal wrote:
> > Some programs require ability to accept packets destined to certain
> > MAC addresses (in addition to their own).
> > Example Jerome Ettienes vrrpd (http://w3.arobas.net/~jetienne/vrrpd/)
> > 
> > The trick is to add unicast addresses via SIOCADDMULTI and accept those
> > packets when they make their way up the stack.
> > I think this used to work, no? Donald, any history/comments behind
> > this?
> 
> Over and above Donald's comments, from an interface perspective I think 
> this is a bit of a hack, don't you?  :)  Calling an "add-multi" ioctl 
> should do precisely that... and only that :)

Yes, it is totally a hack, not an interface.

It was
  "If you need this capability for a RESEARCH PROJECT, you can buy this
  specific board and thus not need to modify the kernel or device
  driver. "

You can also find a few people that want to receive specific corrupted
packets, change the meaning of LEDs on a NIC, and do many other strange
things.  But we don't need a defined kernel interface for each one.

Improvement is what you can eliminate or simplify, not adding complexity.


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
