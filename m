From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: ip -6 route shows incorrect route expiry times
Date: Mon, 31 Jan 2005 01:29:10 +0900 (JST)
Message-ID: <20050131.012910.117562374.yoshfuji@linux-ipv6.org>
References: <20050130160840.C25000@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk@arm.linux.org.uk
In-Reply-To: <20050130160840.C25000@flint.arm.linux.org.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050130160840.C25000@flint.arm.linux.org.uk> (at Sun, 30 Jan 2005 16:08:40 +0000), Russell King <rmk@arm.linux.org.uk> says:

> rmk@dyn-67:[bk]:<1030> /sbin/ip -6 route; sleep 10; /sbin/ip -6 route
> default via fe80::a00:2bff:fe95:1d7b dev eth0  proto kernel  metric 1024
>   expires 169sec mtu 1500 advmss 1440
> default via fe80::a00:2bff:fe95:1d7b dev eth0  proto kernel  metric 1024
>   expires 168sec mtu 1500 advmss 1440
> 
> It appears that the expiry seconds here are actually in units of
> 10 seconds.  Maybe someone's double-converting kernel Hz to user Hz?

Kernel exports in USER_HZ.
iproute2 seem to convert it again; workaround is to do "export HZ=100".

--yoshfuji
