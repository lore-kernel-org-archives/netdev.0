From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Tue, 06 May 2003 07:25:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030506.072529.52888036.davem@redhat.com>
References: <20030502.134804.78707298.davem@redhat.com>
	<20030503040949.804182C003@lists.samba.org>
	<20030505090820.50cd5a13.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030505090820.50cd5a13.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 5 May 2003 09:08:20 -0700

   On Sat, 03 May 2003 14:07:41 +1000
   Rusty Russell <rusty@rustcorp.com.au> wrote:
   
   > But Alexey said you can only call unregister_netdev from module
   > unload, ie. if not a module, it can't be unloaded, hence no refcount
   > needed.  I wrote the above paragraph because I'm not sure if I
   > understood Alexey correctly?

   There are several flavors of pseudo-network devices like bridging
   and VLAN that dynamically create/destroy netdev's even when they
   are not modules.

I think you'll understand what Alexey/Rusty are saying better
if you consider statically compiled kernel code as a module with
an implicit non-zero reference count :-)

   
