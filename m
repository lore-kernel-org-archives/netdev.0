From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 IPSEC support
Date: Sun, 23 Feb 2003 09:44:42 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223.094442.107718872.yoshfuji@linux-ipv6.org>
References: <20030222.031326.103246837.davem@redhat.com>
	<20030222.214935.134101784.yoshfuji@linux-ipv6.org>
	<20030222.154753.133994666.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org, kunihiro@ipinfusion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030222.154753.133994666.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030222.154753.133994666.davem@redhat.com> (at Sat, 22 Feb 2003 15:47:53 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> One example, xfrm_lookup() gets this xfrm_afinfo pointer, and it can
> use it to learn how to compare addresses.  The xfrm_afinfo pointer
> is also passed to xfrm_bundle_create() which uses it to learn how
> to lookup tunnel routes.
> 
> A small net/ipv6/xfrm_ipv6.c module is created, which registers
> a xfrm_afinfo structure to the generic xfrm engine, it teaches
> how to do these operations for AF_INET6 xfrm objects.
> 
> Do you think this can work?

I suppose so.  We'll try to work on it.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
