From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6] watch64: generic variable monitoring system
Date: Sat, 04 Sep 2004 04:07:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040904.040727.72671952.yoshfuji@linux-ipv6.org>
References: <200409031307.01240.jeffpc@optonline.net>
	<200409031319.24863.jeffpc@optonline.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jeffpc@optonline.net
In-Reply-To: <200409031319.24863.jeffpc@optonline.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200409031319.24863.jeffpc@optonline.net> (at Fri, 03 Sep 2004 13:19:24 -0400), "Josef 'Jeff' Sipek" <jeffpc@optonline.net> says:

> The watch64 system allows the programmer to specify the approximate interval
> at which he wants his variables checked. If he tries to specify shorter
> interval than the minimum a default value of HZ/10 is used. To minimize
> locking, RCU and seqlock are used. On 64-bit systems, all is optimized away.

I agree with the basic principle; it is very similar to mine.
However, it is too complicated isn't it?
I would do per-"table" registration (instead of per-variable one);
watch64_getval() seems very ugly to me...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
