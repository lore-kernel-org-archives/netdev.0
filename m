From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 12:34:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015.123443.62397799.davem@redhat.com>
References: <20021015.104014.34145167.davem@redhat.com>
	<Pine.LNX.4.44.0210151353450.1159-100000@beohost.scyld.com>
	<20021015191626.GD15420@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greg@kroah.com
In-Reply-To: <20021015191626.GD15420@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Greg KH <greg@kroah.com>
   Date: Tue, 15 Oct 2002 12:16:26 -0700
   
   That being said, a number of people have asked that the networking hooks
   be able to "be compiled away", so we will be glad to do this.

That's the only big beef I have with the LSM stuff,
on a whole.

I want to be able to say CONFIG_SECURITY=n and all of
this stuff totally disappears.  So use macros that expand
to the security_ops->foo() when it's enabled, and compile
into do { } while (0) when it is disabled.

And yes, as much as the LSM folks may hate it, I want distribution
makes to be able to turn this stuff off at their discretion as well.

Some may decide that supporting a mechanism like this in their kernel
is just too much.
