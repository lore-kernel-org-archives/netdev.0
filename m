From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [IPV6 0/3] Deprecate IPv6 Routing Header Type 0.
Date: Mon, 18 Jun 2007 15:34:24 +0900 (JST)
Message-ID: <20070618.153424.27464098.yoshfuji@linux-ipv6.org>
References: <20070618.150200.19276134.yoshfuji@linux-ipv6.org>
	<20070617.231749.18606024.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40406 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757830AbXFRGeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 02:34:04 -0400
In-Reply-To: <20070617.231749.18606024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070617.231749.18606024.davem@davemloft.net> (at Sun, 17 Jun 2007 23:17:49 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> > [PATCH 1/3] [IPV6]: Restore semantics of Routing Header processing.
> > [PATCH 2/3] [IPV6]: Do not send RH0 anymore.
> > [PATCH 3/3] [IPV6]: Make IPV6_{RECV,2292}RTHDR boolean options.
> 
> I think it is sufficient to schedule this for 2.6.23 and not
> to rush it into 2.6.22
> 
> Do you agree?

I agree for 3/3 (and 2/3, maybe).

On the other hand, I would rather like to push 1/3 to 2.6.21-stable
and 2.6.22(-stable) to restore the basic semantics, if possible.
Or I need to put the patch(es) on-line for users.

--yoshfuji
