From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV6 0/3] Deprecate IPv6 Routing Header Type 0.
Date: Sun, 17 Jun 2007 23:17:49 -0700 (PDT)
Message-ID: <20070617.231749.18606024.davem@davemloft.net>
References: <20070618.150200.19276134.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43450
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750713AbXFRGRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 02:17:31 -0400
In-Reply-To: <20070618.150200.19276134.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 18 Jun 2007 15:02:00 +0900 (JST)

> I think the IETF community is reaching consensus on deprecation of
> RH0 (Routing Header Type 0).  RH0 is now handled as unknown RH type,
> e.g, accept it if segleft == 0, or send ICMPv6 Parameter Problem to
> the sender.
> 
> [PATCH 1/3] [IPV6]: Restore semantics of Routing Header processing.
> [PATCH 2/3] [IPV6]: Do not send RH0 anymore.
> [PATCH 3/3] [IPV6]: Make IPV6_{RECV,2292}RTHDR boolean options.

I think it is sufficient to schedule this for 2.6.23 and not
to rush it into 2.6.22

Do you agree?

Thanks!
