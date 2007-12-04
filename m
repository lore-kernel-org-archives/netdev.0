From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: XFRM and IPv6 raw sockets and multicast
Date: Tue, 04 Dec 2007 08:08:11 -0800 (PST)
Message-ID: <20071204.080811.100536010.yoshfuji@linux-ipv6.org>
References: <9c46321e0712040727tee578cm97a83936fefb34ed@mail.gmail.com>
	<20071204.075201.108501440.yoshfuji@linux-ipv6.org>
	<9c46321e0712040801w72e31178t940ca70ccfd8a14a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hugosantos@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42889 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbXLDQHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 11:07:52 -0500
In-Reply-To: <9c46321e0712040801w72e31178t940ca70ccfd8a14a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

In article <9c46321e0712040801w72e31178t940ca70ccfd8a14a@mail.gmail.com> (at Tue, 4 Dec 2007 17:01:43 +0100), "Hugo Santos" <hugosantos@gmail.com> says:

> > If we do really support it, if hdcincl is set, XFRM and other
> > all extension header processes should be skipped, but they are
> > not very clear at all so far.
> 
>   I understand how some users of IPPROTO_RAW would want xfrm to be
> skipped, but on the other hand i also see the interoperation between
> the two as useful, to for instance allowing a ESP tunnel to be used by
> such packets.

I do think all extension header, including fragment and/or XFRM, process
should be skipped if hdrincl is set.

--yoshfuji
