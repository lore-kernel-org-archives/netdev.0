From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] Fix ICMPv6 redirect handling with target multicast
 address
Date: Mon, 01 Oct 2007 20:49:21 +0900 (JST)
Message-ID: <20071001.204921.52365121.yoshfuji@linux-ipv6.org>
References: <46FD2B37.6040502@hp.com>
	<OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com>
	<20070929.100448.41933886.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: brian.haley@hp.comy, dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:51235 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbXJALrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 07:47:36 -0400
In-Reply-To: <20070929.100448.41933886.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <20070929.100448.41933886.yoshfuji@linux-ipv6.org> (at Sat, 29 Sep 2007 10:04:48 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <OF5FC97D70.5FD0A80A-ON88257365.00025E58-88257365.00048D1E@us.ibm.com> (at Fri, 28 Sep 2007 17:50:38 -0700), David Stevens <dlstevens@us.ibm.com> says:
> 
> > Brian,
> >         A multicast address should never be the target of a neighbor
> > discovery request; the sender should use the mapping function for all
> > multicasts. So, I'm not sure that your example can ever happen, and it
> > certainly is ok to send ICMPv6 errors to multicast addresses in general.
> > But I don't see that it hurts anything. either (since it should never 
> > happen :-)),
> > so I don't particularly object, either.
> >         I think it'd also be better if you add the check to be:
> > 
> >         if (ipv6_addr_type(target) & 
> > (IPV6_ADDR_LINKLOCAL|IPV6_ADDR_UNICAST))
> > 
> > or something along those lines, rather than reproducing ipv6_addr_type() 
> > code
> > separately in a new ipv6_addr_linklocal() function.

I'm fine with the idea of the fix itself.

Please use ipv6_addr_type() so far and convert other users as well
to ipv6_addr_linklocal() in another patch.

Regards,

--yoshfuji

