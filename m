From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: why cannot unload ipv6 module ?
Date: Fri, 15 Nov 2002 07:48:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021115.074825.16291557.yoshfuji@linux-ipv6.org>
References: <001801c28bb8$cd749c50$6c06a8c0@zhengjp>
	<20021114.180104.77076139.yoshfuji@linux-ipv6.org>
	<000e01c28bd1$ffdaf2c0$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: zjp@iscas.ac.cn
In-Reply-To: <000e01c28bd1$ffdaf2c0$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <000e01c28bd1$ffdaf2c0$6c06a8c0@zhengjp> (at Thu, 14 Nov 2002 19:35:57 +0800), "Zheng Jianping" <zjp@iscas.ac.cn> says:

> > > I complie IPv6 as module and install it. But when I try to unload it, I
> failed.
> > > How can I make IPv6 module unload?
> >
> > unloading ipv6 module is not supported.
> >
> Can I modify the IPv6 source code to make unloading supported?

You could.


> If yes, how to modify it?

In fact, you can unload if you pass "unloading=1" when loading.
But, rmmod ipv6 does not work properly and we cannot insmod ipv6 again.
We've fixed this (and code is in our (USAGI Project 
<http://www.linux-ipv6.org>'s) tree), but kernel panics if we unloaded 
ipv6 module when *any* ipv6 sockets exist.

BTW, Don't you think that if we knew all, we've done it? :-)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
