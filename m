From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] Fix ICMPv6 redirect handling with target multicast
 address
Date: Sat, 29 Sep 2007 10:04:48 +0900 (JST)
Message-ID: <20070929.100448.41933886.yoshfuji@linux-ipv6.org>
References: <46FD2B37.6040502@hp.com>
	<OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: dlstevens@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46941 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbXI2BDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 21:03:06 -0400
In-Reply-To: <OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, Brian,

Let me double check this patch.

Regards,

--yoshfuji

In article <OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com> (at Fri, 28 Sep 2007 17:50:38 -0700), David Stevens <dlstevens@us.ibm.com> says:

> Brian,
>         A multicast address should never be the target of a neighbor
> discovery request; the sender should use the mapping function for all
> multicasts. So, I'm not sure that your example can ever happen, and it
> certainly is ok to send ICMPv6 errors to multicast addresses in general.
> But I don't see that it hurts anything. either (since it should never 
> happen :-)),
> so I don't particularly object, either.
>         I think it'd also be better if you add the check to be:
> 
>         if (ipv6_addr_type(target) & 
> (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST))
> 
> or something along those lines, rather than reproducing ipv6_addr_type() 
> code
> separately in a new ipv6_addr_linklocal() function.
> 
>                                                 +-DLS
> 
> 
