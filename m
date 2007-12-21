From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [TCP] IPV6 : Change a divide into a right shift in
 tcp_v6_send_ack()
Date: Fri, 21 Dec 2007 16:44:58 +0900 (JST)
Message-ID: <20071221.164458.51184496.yoshfuji@linux-ipv6.org>
References: <476B65F8.10201@cosmosbay.com>
	<20071221.162833.82587283.yoshfuji@linux-ipv6.org>
	<476B6DAC.2030102@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44220 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbXLUHoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 02:44:22 -0500
In-Reply-To: <476B6DAC.2030102@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <476B6DAC.2030102@cosmosbay.com> (at Fri, 21 Dec 2007 08:39:24 +0100), Eric Dumazet <dada1@cosmosbay.com> says:

> > Okay, anyway, I'll convert them to unsigned int, which is more
> > appropriate.
> 
> I didnt chose this path, because David was against changing some fields from 
> 'int' to 'unsigned'. If you look in other parts of networking, we have many >> 
> 1 or >> 2 already there.

I do think it is safe to convert them here.

--yoshfuji
