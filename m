From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6: note on shared socket options
Date: Thu, 05 Feb 2004 11:09:55 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040205.110955.10680487.yoshfuji@linux-ipv6.org>
References: <20040204.203739.16838230.yoshfuji@linux-ipv6.org>
	<OF2F9C078B.064A8A19-ON87256E30.0077B005-88256E30.0077AF76@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF2F9C078B.064A8A19-ON87256E30.0077B005-88256E30.0077AF76@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF2F9C078B.064A8A19-ON87256E30.0077B005-88256E30.0077AF76@us.ibm.com> (at Wed, 4 Feb 2004 13:49:51 -0800), David Stevens <dlstevens@us.ibm.com> says:

>       These are defined by draft-ietf-magma-msf-api-03.txt to be in
> netinet/in.h (no place else). What's the advantage of adding another
> copy in in6.h (which currently isn't used by anything)? Portable user apps
> must include netinet/in.h for them, and in-kernel code already does.

(I assume you're talking about the "alternatives.")

Kernel do not use netinet/*.h.

My main point is, do not let people (or myself) forget reserved 
(or used) range.  So, it is enough for me to add a comment on that.


Well, I really do not think that the name of MCAST_xxx is good.
Numeric assignment of "MCAST_xxx" functionalities 
is only required to be unique in that level in theory
since we put MCAST_xxx at network level (IPPROTO_{IP,IPV6} for now).
However, they are share just because of the name.


Anyway, what I want to add is some small note on shared range.
Thanks.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
