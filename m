From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: How to get IPv6 interface?
Date: Thu, 28 Nov 2002 21:13:37 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021128.211337.92231995.yoshfuji@linux-ipv6.org>
References: <004c01c29679$52812600$6c06a8c0@zhengjp>
	<8120000.1038471604@gate.muc.bieringer.de>
	<20021128111600.GA30967@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ahu@ds9a.nl
In-Reply-To: <20021128111600.GA30967@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021128111600.GA30967@outpost.ds9a.nl> (at Thu, 28 Nov 2002 12:16:00 +0100), bert hubert <ahu@ds9a.nl> says:

> > > I'm writing an IPv6 application, so which function can get the IPv6
> > > inteface information? And how to call it?
> > 
> > Sorry, I'm not really an IPv6 programmer, hopefully others can help
> > you.
> 
> The best way is probably to look at the 'ip' sources which use netlink to
> query the kernel.

You may want to use getifaddrs() in USAGI libinet6.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
