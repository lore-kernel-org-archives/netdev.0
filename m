From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: XFRM and IPv6 raw sockets and multicast
Date: Tue, 04 Dec 2007 07:52:01 -0800 (PST)
Message-ID: <20071204.075201.108501440.yoshfuji@linux-ipv6.org>
References: <9c46321e0712040727tee578cm97a83936fefb34ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hugosantos@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42886 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146AbXLDPvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 10:51:42 -0500
In-Reply-To: <9c46321e0712040727tee578cm97a83936fefb34ed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <9c46321e0712040727tee578cm97a83936fefb34ed@mail.gmail.com> (at Tue, 4 Dec 2007 16:27:50 +0100), "Hugo Santos" <hugosantos@gmail.com> says:

>   The behavior is the same as in UDP, but ipv6_pinfo->saddr is not
> usually set for these kind of sockets. I would say that if fl6_src is
> any, it should be copied from the ipv6 header.

What do you mean by "ipv6 header"?

>   Another question is why does raw.c require a msg_name? If
> inet->hdrincl was set, it could use the ipv6 header destination
> address in the absense of msg_name.

I think hdrincl is broken (and even, say, deprecated) on IPv6.

If we do really support it, if hdcincl is set, XFRM and other
all extension header processes should be skipped, but they are
not very clear at all so far.

--yoshfuji
