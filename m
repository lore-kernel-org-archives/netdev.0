From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: ip -6 route shows incorrect route expiry times
Date: Mon, 31 Jan 2005 01:30:18 +0900 (JST)
Message-ID: <20050131.013018.131301320.yoshfuji@linux-ipv6.org>
References: <20050130160840.C25000@flint.arm.linux.org.uk>
	<20050131.012910.117562374.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rmk@arm.linux.org.uk
In-Reply-To: <20050131.012910.117562374.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050131.012910.117562374.yoshfuji@linux-ipv6.org> (at Mon, 31 Jan 2005 01:29:10 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> > It appears that the expiry seconds here are actually in units of
> > 10 seconds.  Maybe someone's double-converting kernel Hz to user Hz?
> 
> Kernel exports in USER_HZ.
> iproute2 seem to convert it again; workaround is to do "export HZ=100".
                                                          ~~~~~~~~~~~~~
This is example. Of course, this depends on your arch.

--yoshfuji
