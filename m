From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch]IPv6: fix BUG of ndisc_send_redirect()
Date: Sun, 14 Jan 2007 23:13:27 +0900 (JST)
Message-ID: <20070114.231327.101009448.yoshfuji@linux-ipv6.org>
References: <1168679560.3639.11.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:45779 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbXANOMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Jan 2007 09:12:32 -0500
To: lyw@nanjing-fnst.com
In-Reply-To: <1168679560.3639.11.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <1168679560.3639.11.camel@localhost.localdomain> (at Sat, 13 Jan 2007 17:12:40 +0800), Li Yewang <lyw@nanjing-fnst.com> says:

>   When I tested IPv6 redirect function about kernel 2.6.19.1, and found
> that the kernel can send redirect packets whose target address is global
> address, and the target is not the actual endpoint of communication.
:
> So, I think the send redirect function must check the target address
> also.

It is not mandatory, however, it is better to do this.  I agree.
(Note: In usual, we do not install gateway'ed route with global
next-hop.)

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
