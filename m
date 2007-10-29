From: David Miller <davem@davemloft.net>
Subject: Re: Oops in 2.6.21-rc4, 2.6.23
Date: Mon, 29 Oct 2007 01:41:47 -0700 (PDT)
Message-ID: <20071029.014147.56411400.davem@davemloft.net>
References: <20071015173956.6c554387@beavis.confused.org>
	<20071029084232.GA2280@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: darko.koruga@siol.net, netdev@vger.kernel.org
To: jarkao2@o2.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55192
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752017AbXJ2Ilu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 04:41:50 -0400
In-Reply-To: <20071029084232.GA2280@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@o2.pl>
Date: Mon, 29 Oct 2007 09:42:32 +0100

> I hope you've found this by yourself by now, but:
> 
> 1. These are warnings only - not oopses.
> 2. It seems this patch you've found to be responsible for this all
> slightly changes some limits, which is not necessarily wrong; the
> lucky thing is you can change these limits with sysctl or some
> echos to /proc/sys/net/ipv4/tcp_mem, I presume. (Or more safely by
> adding some memory.)

Actually, this was caused by a real bug in the SKB_WITH_OVERHEAD macro
definition, which Herbert Xu quickly spotted and fixed.

Which "I hope you've found this by yourself by now".
