From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 IPSEC support
Date: Sat, 22 Feb 2003 21:49:35 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030222.214935.134101784.yoshfuji@linux-ipv6.org>
References: <20030222202623.38d41d8a.kazunori@miyazawa.org>
	<20030222.031326.103246837.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org, kunihiro@ipinfusion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030222.031326.103246837.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

In article <20030222.031326.103246837.davem@redhat.com> (at Sat, 22 Feb 2003 03:13:26 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:

> Nothing in xfrm routines really need to reference ipv6 module
> functions, please eliminate this dependency.  Breaking ipv6 as module
> is ok for temporary development, but eventually it must be solved.

xfrm_policy.c:xfrm6_bundle_create() seems to depend on ip6_route_output()
as xfrm_bundle_create() depends on __ip_route_output_key().
How do we solve this dependency? inter-module?

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
