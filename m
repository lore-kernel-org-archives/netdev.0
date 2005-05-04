From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 1/1] addrconf.h build fix
Date: Tue, 3 May 2005 21:51:30 -0700
Message-ID: <20050503215130.0526178c.davem@davemloft.net>
References: <200505040456.j444u6sS004479@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
In-Reply-To: <200505040456.j444u6sS004479@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 03 May 2005 21:55:40 -0700
akpm@osdl.org wrote:

> On ppc64:
> 
> In file included from net/ipv6/xfrm6_policy.c:18:
> include/net/addrconf.h:40: error: field `prefix' has incomplete type
> 
> This surely patch isn't right, and might break userspace inclusion of this
> header file.

I've got a fix in my queue for this already.

In fact, the patch in question was posted to netdev@oss.sgi.com
a few hours ago, you may wish to start scanning that list before
posting patches :-)
