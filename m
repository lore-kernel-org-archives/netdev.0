From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Miscellaneous clean-ups
Date: Fri, 04 Oct 2002 07:39:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021004.073925.101556969.yoshfuji@linux-ipv6.org>
References: <20021004.011315.05129566.yoshfuji@linux-ipv6.org>
	<20021003.103617.04446177.davem@redhat.com>
	<20021004.073642.125593159.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20021004.073642.125593159.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20021004.073642.125593159.yoshfuji@linux-ipv6.org> (at Fri, 04 Oct 2002 07:36:42 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> I saw many __constant_{hton,ntoh}{s,l}()s, so fixed.
> 
>       1. use s6_addrXX instead of in6_u.s6_addrXX.
>       2. avoid using magic number.
>       3. use 32bit constants.
>  -->  4. avoid __constant_{hton,ntoh}{l,s}() in runtime code.

oops, sorry, not fixed in my fix... :-p
just a moment, please...

--yoshfuji
