From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] netdev_ops
Date: Thu, 10 Jul 2003 13:37:37 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710.133737.41660806.davem@redhat.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0102229134@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0102229134@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Feldman, Scott" <scott.feldman@intel.com>
   Date: Thu, 10 Jul 2003 01:18:50 -0700
   
   With HAVE_NETDEV_OPS, you're right, we're maintaining the wrapper
   code outside the kernel.  But, it does leave the possibility of
   having a shared backwards compatibility code for multiple (all?)
   drivers for those stuck with supporting kernels without netdev_ops. 
   
And precisely I am showing you how all this backwards compat
stuff is going to hurt you.  You can never truly take advantage
of things that eliminate duplicated code in all the drivers,
and this netdev_ops case is a great example.
