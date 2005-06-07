From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: IPV6 RFC3542 compliance [PATCH]
Date: Tue, 07 Jun 2005 15:33:59 +0900 (JST)
Message-ID: <20050607.153359.82068814.yoshfuji@linux-ipv6.org>
References: <20050607.141922.65612976.yoshfuji@linux-ipv6.org>
	<OF9F62ECDB.67FFA191-ON88257019.001F5EA8-88257019.00234AB6@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF9F62ECDB.67FFA191-ON88257019.001F5EA8-88257019.00234AB6@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF9F62ECDB.67FFA191-ON88257019.001F5EA8-88257019.00234AB6@us.ibm.com> (at Mon, 6 Jun 2005 23:25:28 -0700), David Stevens <dlstevens@us.ibm.com> says:

> And those same binaries would not work when recompiled,
> because the option names in the source would match the
> new numbers, but still have the old arguments-- an error to
> be detected at run-time, only.

It is not good at all to break API at this moment (2.6.x).

Portable applications do like this:

#ifdef IPV6_RECVHOPOPTS
   // RFC2292bis
#else
   // RFC2292
#endif

--yoshfuji
