From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 19:47:13 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.194713.21412719.yoshfuji@linux-ipv6.org>
References: <20030711.180449.126456521.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0307111301520.27036-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mika.liljeberg@welho.com, andre@tomt.net, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0307111301520.27036-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0307111301520.27036-100000@netcore.fi> (at Fri, 11 Jul 2003 13:03:54 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> > We have but we cannot; it is refcnt'ed.
> 
> I don't understand what you mean.  Refcnt'ed by a userland process, so 
> that if you'd want the subnet-router anycast address, the whole time a 
> process (like radvd) should be running.. or what?

Kernel has refcnt for subnet router anycast address.
Ref/dereference from userspace is done via socket.
You cannot derefer subnet router anycast address 
from userspace if the socket hasn't refered it.

--yoshfuji
