From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 12:45:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015194545.GC15864@kroah.com>
References: <20021015.104014.34145167.davem@redhat.com> <Pine.LNX.4.44.0210151353450.1159-100000@beohost.scyld.com> <20021015191626.GD15420@kroah.com> <20021015.123443.62397799.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20021015.123443.62397799.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2002 at 12:34:43PM -0700, David S. Miller wrote:
>    From: Greg KH <greg@kroah.com>
>    Date: Tue, 15 Oct 2002 12:16:26 -0700
>    
>    That being said, a number of people have asked that the networking hooks
>    be able to "be compiled away", so we will be glad to do this.
> 
> That's the only big beef I have with the LSM stuff,
> on a whole.
> 
> I want to be able to say CONFIG_SECURITY=n and all of
> this stuff totally disappears.  So use macros that expand
> to the security_ops->foo() when it's enabled, and compile
> into do { } while (0) when it is disabled.

Fair enough, mind if I create a CONFIG_SECURITY_NETWORK that we can use
for this?

The other LSM hooks seem to be working just fine compiled in, but I can
understand the network speed issues.

thanks,

greg k-h
