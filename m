From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: [PATCH] netdev_ops
Date: Thu, 10 Jul 2003 01:18:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E0102229134@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <willy@debian.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Don't tell me you're seriously considering having _TWO_ 
> copies of all this code sitting around?
> 
> At that point backwards compat becomes absolutely 
> rediculious.  If it's important to you, just stick to the 
> current scheme.  You gain nothing by maintaining two copies 
> of the same code.

Either way we end up with duplicated code.  If I stick with the current
scheme (no netdev_ops), I duplicate in the driver all of the wrapper
code that Matt has pulled into netdev_ops.  Each driver that sticks to
the current scheme duplicates Matt's code.  With HAVE_NETDEV_OPS, you're
right, we're maintaining the wrapper code outside the kernel.  But, it
does leave the possibility of having a shared backwards compatibility
code for multiple (all?) drivers for those stuck with supporting kernels
without netdev_ops. 
