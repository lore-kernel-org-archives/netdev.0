From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: kill in6_u.u6_addrX
Date: Thu, 12 Feb 2004 15:20:41 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040212.152041.71631987.yoshfuji@linux-ipv6.org>
References: <20040212.140022.128605177.yoshfuji@linux-ipv6.org>
	<OFE6A4DD6C.ACB3D0B4-ON88256E38.001F6E3F-88256E38.0020FDCB@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFE6A4DD6C.ACB3D0B4-ON88256E38.001F6E3F-88256E38.0020FDCB@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFE6A4DD6C.ACB3D0B4-ON88256E38.001F6E3F-88256E38.0020FDCB@us.ibm.com> (at Wed, 11 Feb 2004 22:03:04 -0800), David Stevens <dlstevens@us.ibm.com> says:

> Not related to what you're trying to fix, and I haven't
> checked if more recent standards have defined them, but
> if not, me might want to look at changing these to
> 
> #define _s6_addr32      _S6_un._s6_u32

Please don't.

Userspace uses sockaddr_in6 defined in glibc, not one in kernel.
It is glibc issue.

Well, it is one of my TODO to revisit IPv6 related headers.
They're not friendly with glibc headers...

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
