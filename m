From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow
 Both IPv6 and IPv4 Sockets on the Same Port)
Date: Wed, 23 Oct 2002 19:01:31 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021023.190131.67057125.yoshfuji@linux-ipv6.org>
References: <20021023.162439.114324450.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210231031540.26788-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210231031540.26788-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210231031540.26788-100000@netcore.fi> (at Wed, 23 Oct 2002 10:36:19 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> Does Bind 9.2.1 work this so that it can receive packets, when IPv6 is
> also enabled, from IPv4 addresses using TCP without
> 'match-mapped-addresses yes', or is that a separate problem?

Bind9 trys to bind :: and all ipv4 addresses on the node.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
