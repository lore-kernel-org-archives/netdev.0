From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 12:45:02 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015.124502.130514745.davem@redhat.com>
References: <20021015191626.GD15420@kroah.com>
	<20021015.123443.62397799.davem@redhat.com>
	<20021015194545.GC15864@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greg@kroah.com
In-Reply-To: <20021015194545.GC15864@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Greg KH <greg@kroah.com>
   Date: Tue, 15 Oct 2002 12:45:45 -0700

   Fair enough, mind if I create a CONFIG_SECURITY_NETWORK that we can use
   for this?
   
Why special case networking?  Do it for everything.

2.5.x can use all the help it can get in the debloating
department.  It's currently busting at the seams.

security/*.o takes up space in my kernel and achieves ABSOLUTELY
NOTHING but take up space, the same goes for all the security_ops->()
invocations all over the place.

You must allow the user to config this stuff out of their tree.
