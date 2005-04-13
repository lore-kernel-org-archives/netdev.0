From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPV6_CHECKSUM socket option can corrupt kernel memory
Date: Wed, 13 Apr 2005 13:05:35 +0900 (JST)
Message-ID: <20050413.130535.121024536.yoshfuji@linux-ipv6.org>
References: <20050413.095308.124546011.yoshfuji@linux-ipv6.org>
	<OF0A4F590E.3F5A449F-ON88256FE2.000E49F8-88256FE2.000F289A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com, davem@davemloft.net
In-Reply-To: <OF0A4F590E.3F5A449F-ON88256FE2.000E49F8-88256FE2.000F289A@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF0A4F590E.3F5A449F-ON88256FE2.000E49F8-88256FE2.000F289A@us.ibm.com> (at Tue, 12 Apr 2005 19:45:34 -0700), David Stevens <dlstevens@us.ibm.com> says:

> csum has to be a pointer into the packet data, so it can store
> the checksum it computes for the outgoing packet at that (user-provided)
> offset. It looks like skb_header_pointer gives a copy of the
> existing value, pointing to csum_buff, which wouldn't modify the
> packet value, right? So, I don't think that'll work.

Ok, understood.

BTW, I remember that my first intention was that we restrict "checksum"
should be placed within the first fragment.
In this sense, rp->offset + 1 < len does not make sense to me,
if there's more fragments.
Anyway, please allow me some time...

--yoshfuji
